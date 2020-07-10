//
//  ContentView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var progress: Double = 0.0
    @State var showModal: Bool = false
    @State var showPopover: Bool = false
    @State var errorMessage: String? = nil
    @State var error: Bool = false
    
    @State var modifiableEvent: Event?
    @State var now: Date = Date()
    @State var confettiView = ConfettiUIView()
        
    @EnvironmentObject var model: Model
    
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    
    var alertButtons: [Alert.Button] {
        return Model.SortableKeyPaths.map { key, _ in
            .default(Text(key)) { model.sortedKey = key }
        }
    }
    
    func onEventEnd() {
        self.confettiView.emit(with: [.text("🎉")])
        AudioManager.shared.play("Success 1.mp4")
        
        let taptics = UINotificationFeedbackGenerator()
        taptics.notificationOccurred(.success)
    }
    
    var grid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(model.events, id: \.self) { event in
                SmallCardView(event: event)
                    .contextMenu {
                        Button(action: {
                            self.modifiableEvent = event
                            withAnimation {
                                self.showModal = true
                            }
                        }) {
                            Text("Edit")
                            Image(systemName: "slider.horizontal.3")
                        }
                        
                        Button(action: {
                            model.removeEvent(event) { _ in }
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                    .id("\(showModal)\(event.hashValue)")
                //.animation(.linear)
            }
            
            AddEventButtonView() {
                self.modifiableEvent = nil
                self.showModal = true
            }
        }
        .navigationBarTitle(Text("My Events"), displayMode: .large)
        .navigationBarItems(
            leading: Button(action: { }) {
                Image(systemName: "ellipsis")
                    .imageScale(.large)
            },
            trailing: Button(action: { self.showPopover = true }) {
                Image(systemName: "arrow.up.arrow.down").imageScale(.large)
            }
            .actionSheet(isPresented: $showPopover) {
                ActionSheet(title: Text("Sort Events"), buttons: alertButtons + [.cancel()])
            }
        )
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    grid.padding(.horizontal, 16)
                }
                .padding(.top)
            }

            EmptyView().id("\(self.now.hashValue)")
        }
        .overlay(
            UIViewWrapper(view: $confettiView)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
        )
        .sheet(isPresented: $showModal) {
            AddEventView(showModal: $showModal, existingEvent: modifiableEvent) {
                if let event = $0 {
                    self.model.removeEvent(modifiableEvent) { _ in }
                    
                    self.model.addEvent(event) { result in
                        if case .failure(let error) = result {
                            self.errorMessage = error.localizedDescription
                            self.error = true
                        }
                    }
                }
            }
        }
        .alert(isPresented: $error) {
            Alert(
                title: Text("Could not add event to Calendar"),
                message: errorMessage.map { Text($0) },
                dismissButton: .default(Text("OK"))
            )
        }
        .onReceive(timer) { _ in
            if !showModal { self.now = Date() }
            
            let eventHasJustEnded: (Event) -> Bool = {
                -1...0 ~= $0.timeRemaining
            }
            
            if model.events.contains(where: eventHasJustEnded) {
                onEventEnd()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewDevice("iPhone 11 Pro").environmentObject(Model(events: [
            Event(
                name: "My Birthday",
                start: .init(),
                end: .init(timeIntervalSinceNow: 186400),
                gradientIndex: 7
            ),
            Event(
                name: "My Anniversary",
                start: .init(),
                end: .init(timeIntervalSinceNow: 2862500),
                gradientIndex: 1
            ),
            Event(
                name: "New Year's",
                start: .init(),
                end: .init(timeIntervalSinceNow: 86400),
                gradientIndex: 10
            ),
            Event(
                name: "Christmas",
                start: .init(),
                end: .init(timeIntervalSinceNow: 1086400),
                gradientIndex: 0
            ),
            Event(
                name: "New Year's",
                start: .init(),
                end: .init(timeIntervalSinceNow: 86400),
                gradientIndex: 9
            ),
            Event(
                name: "Christmas",
                start: .init(),
                end: .init(timeIntervalSinceNow: 1086400),
                gradientIndex: 11
            )
        ]))
    }
}

//
//  ContentView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI
import AVFoundation
import CoreData

struct ContentView: View {
    @State var progress: Double = 0.0
    @State var showModal: Bool = false
    @State var showPopover: Bool = false
    @State var error: Bool = false
    
    @State var modifiableEvent: Event?
    @State var now: Date = Date()
    @State var confettiView = ConfettiUIView()
    
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    
    @FetchRequest(
        fetchRequest: DataProvider.allEventsFetchRequest()
    ) var events: FetchedResults<Event>
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    var alertButtons: [Alert.Button] {
//        return Model.SortableKeyPaths.map { key, _ in
//            .default(Text(key)) { model.sortedKey = key }
//        }
        return []
    }
    
    func onEventEnd() {
        self.confettiView.emit(with: [.text("🎉")])
        AudioManager.shared.play("Success 1.mp4")
        
        let taptics = UINotificationFeedbackGenerator()
        taptics.notificationOccurred(.success)
    }
    
    var grid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(events) { event in
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
                        
                        Button(action: { DataProvider.shared.removeEvent(event, from: context) }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                    .id("\(showModal)\(event.id!)")
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
                    grid.padding(.horizontal)
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
            AddEventView(showModal: $showModal, existingEvent: modifiableEvent)
        }
        .alert(isPresented: $error) {
            Alert(
                title: Text("Could not add event to Calendar"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onReceive(timer) { _ in
            if !showModal { self.now = Date() }
            
            let eventHasJustEnded: (Event) -> Bool = {
                -1...0 ~= $0.timeRemaining
            }
            
            if events.contains(where: eventHasJustEnded) {
                onEventEnd()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}

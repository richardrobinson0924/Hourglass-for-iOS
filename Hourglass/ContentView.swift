//
//  ContentView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI

struct ContentView: View {
    @State var progress: Double = 0.0
    @State var showModal: Bool = false
    @State var showPopover: Bool = false
    
    @State var modifiableEvent: Event?

    @EnvironmentObject var model: Model
    
    @Namespace var namespace
    
    //let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    
    var alertButtons: [Alert.Button] {
        return Model.SortableKeyPaths.map { key, _ in
            .default(Text(key)) { model.sortedKey = key }
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(model.events, id: \.self) { event in
                        SmallCardView(event: event)
                            .contextMenu {
                                Button(action: {
                                    modifiableEvent = event
                                    withAnimation {
                                        self.showModal = true
                                    }
                                }) {
                                    Text("Edit")
                                    Image(systemName: "slider.horizontal.3")
                                }
                                
                                Button(action: {
                                    model.removeEvent(event)
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                            .matchedGeometryEffect(id: "\(event.hashValue)", in: namespace, isSource: false)
                    }
                    
                    if !showModal {
                        AddEventButtonView(namespace: namespace) {
                            modifiableEvent = nil
                            self.showModal = true
                        }
                    } else {
                        Spacer().frame(height: 100)
                    }
                }
                .padding(.horizontal, 16)
                .navigationTitle("My Events")
                .navigationBarItems(
                    leading: Button(action: { }) {
                        Image(systemName: "ellipsis")
                            .imageScale(.large)
                    },
                    trailing: Button(action: {
                        self.showPopover = true
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .imageScale(.large)
                    }.actionSheet(isPresented: $showPopover) {
                        ActionSheet(
                            title: Text("Sort Events"),
                            buttons: alertButtons + [.cancel()]
                        )
                    }
                )
            }
            //.animation(.linear)
            .brightness(self.showModal ? -0.1 : 0)
            .blur(radius: self.showModal ? 16 : 0)
            
            if self.showModal {
                AddEventView(
                    showModal: $showModal,
                    existingEvent: modifiableEvent,
                    namespace: namespace
                ) { event in
                    self.model.removeEvent(modifiableEvent)
                    self.model.addEvent(event)
                }
                .padding(.horizontal, 16)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Model(events: [
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

//
//  ContentView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI

extension Animation {
    func repeatForever(while expression: Bool) -> Animation {
        return expression ? self.repeatForever(autoreverses: true) : self
    }
}

struct ContentView: View {
    @State var progress: Double = 0.0
    @State var editMode: Bool = false
    @State var angle: Double = 0
    @State var showModal: Bool = false

    @EnvironmentObject var model: Model
    
    @Namespace var namespace
    
    var columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    
    func animate(while condition: Bool) {
        self.angle = condition ? -0.6 : 0
                
        withAnimation(Animation.linear(duration: 0.125).repeatForever(while: condition)) {
            self.angle = 0.6
        }
        
        if !condition {
            self.angle = 0
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(model.events, id: \.self) { event in
                        ZStack(alignment: .topLeading) {
                            SmallCardView(event: event, angle: $angle)
                                .contextMenu {
                                    Button(action: {}) {
                                        Text("Edit")
                                        Image(systemName: "slider.horizontal.3")
                                    }
                                    
                                    Button(action: {
                                        model.removeEvent(event)
                                    }) {
                                        Text("Delete").foregroundColor(.red)
                                        Image(systemName: "trash").foregroundColor(.red).accentColor(.red)
                                    }
                                }
                            
                            if self.editMode {
                                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .accentColor(.red)
                                        .imageScale(.large)
                                        .scaleEffect(1.1)
                                        .background(
                                            Circle().foregroundColor(.white)
                                        )
                                })
                                .offset(x: -7, y: -7)
                            }
                        }
                        .rotationEffect(Angle(degrees: angle))
                    }
                    
                    if !showModal {
                        AddEventButtonView(
                            editMode: $editMode,
                            showModal: $showModal,
                            namespace: namespace
                        )
                    } else {
                        Spacer().frame(height: 100)
                    }
                }
                .padding(.horizontal, 16)
//                .onLongPressGesture {
//                    if !self.editMode {
//                        self.editMode = true
//                        animate(while: self.editMode)
//                    }
//                }
                .navigationTitle("My Events")
                .navigationBarItems(
                    leading: Button(action: { }) {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    },
                    trailing: Button(
                        action: {
                            self.editMode.toggle()
                            animate(while: self.editMode)
                        },
                        label: {
                            !self.editMode
                                ? Text("Edit").fontWeight(.medium)
                                : Text("Done").bold()
                        }
                    )
                )
            }
            //.animation(.linear)
            .brightness(self.showModal ? -0.1 : 0)
            .blur(radius: self.showModal ? 16 : 0)
            
            if self.showModal {
                AddEventView(showModal: $showModal, namespace: namespace)
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

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

extension View {
    func anyView() -> AnyView {
        AnyView(self)
    }
}

struct ContentView: View {
    @State var progress: Double = 0.0
    @State var model: Model
    @State var editMode: Bool = false
    @State var angle: Double = 0
    
    @State var showModal: Bool = false
    
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
        NavigationView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(model.events, id: \.self) { event in
                    SmallCardView(event: event, angle: $angle)
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
        .overlay(
            !self.showModal
                ? EmptyView().anyView()
                : AddEventView(namespace: namespace) { event in
                    if let event = event {
                        Model.shared.events.append(event)
                    }
                    
                    self.showModal = false
                }.anyView()
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: .init(events: [
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
        ])).padding(.horizontal, 16)
    }
}

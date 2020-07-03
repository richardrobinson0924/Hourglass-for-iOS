//
//  ContentView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI

struct ContentView: View {
    @State var progress: Double = 0.0
    @State var model: Model
    @State var editMode: Bool = false
    
    //    var body: some View {
    //        ScrollView {
    //            VStack(spacing: 25) {
    //                ForEach(model.events, id: \.self) { event in
    //                    CardView(event: event).onDrag {
    //                        NSItemProvider.init(item: CodedEvent(event), typeIdentifier: event.name)
    //                    }
    //                }
    //            }
    //            .padding(.top, 50)
    //        }
    //    }
    
    var columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(model.events, id: \.self) { event in
                    SmallCardView(event: event)
                }
                
                Image(systemName: "calendar.badge.plus")
                    .renderingMode(.original)
                    .scaleEffect(1.75)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.black.opacity(0.01)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.blue, lineWidth: 3)
                    )
            }
            .navigationTitle("My Events")
            .navigationBarItems(
                leading: Button(
                    action: {},
                    label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                ),
                trailing: Button(
                    action: {
                        self.editMode = !self.editMode
                    },
                    label: {
                        !self.editMode
                            ? Text("Edit").fontWeight(.medium)
                            : Text("Done").bold()
                    }
                )
            )
        }
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
            )
        ])).padding(.horizontal, 16)
    }
}

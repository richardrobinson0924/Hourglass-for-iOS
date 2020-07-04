//
//  AddEventView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI

struct AddEventView: View {
    @State var eventName: String = ""
    @State var endDate = Date()
    @State var color: Color = Color.blue
    
    let onDismiss: (Event?) -> Void
    
    var namespace: Namespace.ID
    
    init(namespace: Namespace.ID, _ onDismiss: @escaping (Event?) -> Void) {
        self.namespace = namespace
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 25.0) {
            HStack {
                Spacer().frame(width: 44)
                
                Spacer()
                
                Text("Create Event")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button(action: { onDismiss(nil) }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                }
                .frame(width: 44)
            }
            .padding(.bottom, 5)
            .padding(.top, 8)
            
            HStack {
                Text("Name of Event").padding(.trailing, 20)
                
                TextField("My Birthday", text: $eventName)
                    .frame(height: 35)
            }
                        
            DatePicker(
                "Date of Event".padding(toLength: 19, withPad: " ", startingAt: 0),
                selection: $endDate,
                in: Date()...
            )
            .frame(height: 35)
                        
            ColorPicker("Select a Color", selection: $color, supportsOpacity: false)
            .frame(height: 35)
                        
            Button(action: {
                let event = Event(name: eventName, start: .init(), end: endDate, gradientIndex: 0)
                onDismiss(event)
            }) {
                RoundedRectangle(cornerRadius: 13)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .overlay(
                        Text("Add Event")
                            .foregroundColor(.white)
                            .bold()
                    )
                    .padding(.horizontal, 1)
            }
            .padding(.top, 8)
            .disabled(self.eventName.isEmpty)
        }
        .padding(.all, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 16)
        .matchedGeometryEffect(id: "box", in: namespace)
    }
}

struct AddEventView_Previews: PreviewProvider {
    @Namespace static var namespace

    
    static var previews: some View {
        AddEventView(namespace: namespace) { _ in }
            .frame(width: 300)
    }
}

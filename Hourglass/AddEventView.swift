//
//  AddEventView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI

extension View {
    func hidden(if condition: Bool) -> some View {
        return condition ? AnyView(EmptyView()) : AnyView(self)
    }
}

struct ColorChooser<S>: View where S : ShapeStyle {
    let options: [S]
    @Binding var selectedIndex: Int
    
    init(_ options: [S], selectedIndex: Binding<Int>) {
        precondition(!options.isEmpty)
        precondition(0..<options.count ~= selectedIndex.wrappedValue)
        
        self.options = options
        self._selectedIndex = selectedIndex
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Select a Color")
                    .frame(alignment: .leading)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(options[selectedIndex])
                    .frame(width: 50, height: 22)
                    .padding(.trailing, 3)
            }
        
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 22) {
                    ForEach(0..<options.count) { i in
                        Circle()
                            .fill(options[i])
                            .overlay(
                                Circle()
                                    .foregroundColor(.white)
                                    .frame(
                                        width: selectedIndex != i ? 0 : 7,
                                        height: selectedIndex != i ? 0 : 7
                                    )
                                    .animation(
                                        Animation.spring().speed(2)
                                    )
                            )
                            .onTapGesture {
                                self.selectedIndex = i
                            }
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
    }
}

struct AddEventView: View {
    @State var eventName: String = ""
    @State var endDate = Date().addingTimeInterval(60)
    @State var gradientIndex: Int = 0
    
    @Binding var showModal: Bool
    @EnvironmentObject var model: Model
    
    let existingEvent: Event?
    
    let linearGradients: [LinearGradient] = Gradient.gradients.map {
        LinearGradient(
            gradient: $0,
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
    }
    
    let namespace: Namespace.ID
    let onDismiss: (Event) -> Void
    
    var body: some View {
        VStack(spacing: 30.0) {
            HStack {
                Spacer().frame(width: 44)
                
                Spacer()
                
                Text(existingEvent == nil ? "Create Event" : "Edit Event")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    self.showModal = false
                }) {
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
            
            ColorChooser(
                linearGradients,
                selectedIndex: $gradientIndex
            )
            .frame(height: 75)
                        
            Button(action: {
                let event = Event(
                    name: eventName,
                    start: existingEvent?.start ?? Date(),
                    end: endDate,
                    gradientIndex: gradientIndex
                )
                onDismiss(event)
                
                withAnimation {
                    self.showModal = false
                }
            }) {
                RoundedRectangle(cornerRadius: 13)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .overlay(
                        Text(existingEvent == nil ? "Add Event" : "Edit Event")
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
        .animation(.linear)
        .matchedGeometryEffect(id: "box", in: namespace, isSource: true)
        .onAppear {
            if let event = existingEvent {
                self.eventName = event.name
                self.endDate = event.end
                self.gradientIndex = event.gradientIndex
            }
        }
    }

}

struct AddEventView_Previews: PreviewProvider {
    @Namespace static var namespace
    @State static var showModal = false
    
    static var previews: some View {
        AddEventView(showModal: $showModal, existingEvent: nil, namespace: namespace) { _ in }
            .frame(width: 300)
    }
}

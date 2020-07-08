//
//  AddEventView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI
import EventKit
import EventKitUI

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
    @State var viewState: CGSize = .zero
    
    @Binding var showModal: Bool
    
    @EnvironmentObject var model: Model
    
    let existingEvent: Event?
    let yOffset: CGFloat
    
    let linearGradients: [LinearGradient] = Gradient.gradients.map {
        LinearGradient(
            gradient: $0,
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
    }
    
    /// This closure is invoked when the view is dimissed, with a newly created Event passed as its parameter.
    /// If the user cancelled this action, `nil` is passed as the parameter
    let onDismiss: (Event?) -> Void
    
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
                    onDismiss(nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                }
                .frame(width: 44)
            }
            .padding(.bottom, 5)
            .padding(.top, 8)
            
            HStack {
                Text("Event Name").padding(.trailing, 20)
                
                TextField("New Year's Day", text: $eventName)
                    .multilineTextAlignment(.trailing)
                    .frame(height: 35)
            }
            
            
            DatePicker(
                "Event Date    ",
                selection: $endDate,
                in: Date()...,
                displayedComponents: [.date, DatePickerComponents.hourAndMinute]
            )
            .frame(height: 35)
            
            ColorChooser(
                linearGradients,
                selectedIndex: $gradientIndex
            )
            .frame(height: 75)
            
            Button(action: {
                let adjustedEnd = Calendar.current.date(bySetting: .second, value: 0, of: endDate)!
                
                let event = Event(
                    name: eventName,
                    start: existingEvent?.start ?? Date(),
                    end: adjustedEnd,
                    gradientIndex: gradientIndex
                )
                onDismiss(event)
                
            }) {
                RoundedRectangle(cornerRadius: 13)
                    .frame(height: 42)
                    .overlay(
                        Text(existingEvent == nil ? "Add Event" : "Apply Changes")
                            .foregroundColor(.white)
                            .bold()
                    )
            }
            .padding(.top, 8)
            .disabled(self.eventName.isEmpty)
        }
        .padding(.all, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 16)
        .offset(
            x: self.viewState.width,
            y: self.showModal ? viewState.height : yOffset
        )
        .animation(
            .spring(response: 0.3, dampingFraction: 0.75, blendDuration: 0)
        )
        .gesture(
            DragGesture()
                .onChanged { self.viewState = $0.translation }
                .onEnded { _ in self.viewState = .zero }
        )
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
    @State static var showModal = true
    
    static var previews: some View {
        AddEventView(showModal: $showModal, existingEvent: nil, yOffset: 200) { _ in }.padding(.horizontal)
    }
}

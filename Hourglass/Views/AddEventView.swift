//
//  AddEventView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI
import EventKit
import EventKitUI
import Combine
import CoreData

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
                HStack(spacing: 20) {
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
    @State var isAddedToCalendar = true
    @State var gradientIndex: Int = 0
        
    @Binding var showModal: Bool
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
        
    let existingEvent: Event?
    
    let linearGradients: [LinearGradient] = Gradient.gradients.map {
        LinearGradient(
            gradient: $0,
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
    }
    
    var accentColor: Color {
        Gradient.gradients[gradientIndex].stops.first!.color
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Event Name")
                        
                        TextField("New Year's Day", text: $eventName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker(
                        "Event Date     ",
                        selection: $endDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section {
                    ColorChooser(linearGradients, selectedIndex: $gradientIndex).padding(.vertical, 8)
                    
                    Toggle("Add to Calendar", isOn: $isAddedToCalendar)
                        .toggleStyle(SwitchToggleStyle(tint: accentColor))
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle(
                Text(existingEvent == nil ? "Create Event" : "Edit Event"),
                displayMode: .inline
            )
            .navigationBarItems(
                leading: Button(action: {
                    self.showModal.toggle()
                }) {
                    Text("Cancel").foregroundColor(accentColor)
                }, trailing: Button(action: {
                    let adjustedEnd = Calendar.current.date(bySetting: .second, value: 0, of: endDate)!
                                        
                    DataProvider.shared.removeEvent(existingEvent, from: context)
                    
                    DataProvider.shared.addEvent(
                        in: context,
                        name: eventName,
                        range: (existingEvent?.startDate ?? Date())...adjustedEnd,
                        colorIndex: gradientIndex,
                        shouldAddToCalendar: isAddedToCalendar
                    )
                    
                    self.showModal.toggle()
                }) {
                    Text("Add").bold().foregroundColor(accentColor)
                }
                .disabled(eventName == "" || endDate <= Date()))
                .accentColor(accentColor)
                .onAppear {
                    if let event = existingEvent {
                        self.eventName = event.name!
                        self.endDate = event.endDate!
                        self.gradientIndex = Int(event.colorIndex)
                    }
                }
        }
    }
    
}


struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}

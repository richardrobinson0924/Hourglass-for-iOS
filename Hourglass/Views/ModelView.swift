//
//  ModelView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-17.
//

import SwiftUI
import CoreData

struct ModelView: View {
    @FetchRequest(
        fetchRequest: DataProvider.allEventsFetchRequest()
    ) var events: FetchedResults<Event>
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    var body: some View {
        ContentView(events: events)
    }
}

struct ModelView_Previews: PreviewProvider {
    static let context = HourglassApp.container.viewContext
    
    static var previews: some View {
//        let event = Event(context: context)
//
//        event.startDate = Date()
//        event.endDate = Date() + 86400
//        event.colorIndex = 1
//        event.name = "Biryda"
//        event.id = UUID()
//
//        DataProvider.shared.addEvent(to: context, name: "My Birthday", range: .init(start: .now, duration: .oneDay), index: 0, shouldAddToCalendar: true)
        
        return ModelView()
            .environment(\.managedObjectContext, context)
    }
}

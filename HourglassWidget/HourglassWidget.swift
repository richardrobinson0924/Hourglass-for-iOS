//
//  HourglassWidget.swift
//  HourglassWidget
//
//  Created by Richard Robinson on 2020-07-03.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: TimelineProvider {
    let managedObjectContext: NSManagedObjectContext
    var endTimelineProvided = false
    
    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(HourglassWidget.placeholderEntry)
    }
    
    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let now = Date()
        
        let fetchRequest = DataProvider.allEventsFetchRequest()
        fetchRequest.fetchLimit = 1
        let events = try! self.managedObjectContext.fetch(fetchRequest)
        
        let entry: Entry
        let targetDate: Date
        
        if let event = events.first {
            targetDate = endTimelineProvided
                ? now + .day * 10
                : event.endDate!
            
            entry = SimpleEntry(
                date: targetDate,
                name: event.name!,
                range: .init(start: event.startDate!, end: event.endDate!),
                gradient: Gradient.all[Int(event.colorIndex)]
            )
        } else {
            targetDate = now + .day * 10
            entry = HourglassWidget.placeholderEntry
        }
        
        let timeline = Timeline(entries: [entry], policy: .after(targetDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    static let closeEnoughFactor: TimeInterval = 2.0 * 60
    
    public let date: Date
    
    public let name: String
    public let range: DateInterval
    public let gradient: Gradient
    
    var isCloseToEnd: Bool {
        return -Self.closeEnoughFactor...Self.closeEnoughFactor ~= range.end.timeIntervalSinceNow
    }
    
    var relevance: TimelineEntryRelevance? {
        let timeSinceNow = range.end.timeIntervalSinceNow
        
        return isCloseToEnd
            ? TimelineEntryRelevance(score: 100.0, duration: timeSinceNow + Self.closeEnoughFactor)
            : TimelineEntryRelevance(score: 10.0)
    }
}

struct HourglassWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: SimpleEntry
    
    var body: some View {
        SmallCardView(name: entry.name, range: entry.range, gradient: entry.gradient)
    }
}

@main
struct HourglassWidget: Widget {
    private let kind: String = "HourglassWidget"
    
    static let placeholderEntry = SimpleEntry(
        date: .now,
        name: "-----------",
        range: .init(start: .now, duration: .oneDay - 59),
        gradient: Gradient.all[9]
    )
    
    let container = DataProvider.shared.container
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider(managedObjectContext: container.viewContext),
            placeholder: HourglassWidgetEntryView(entry: Self.placeholderEntry)
        ) { entry in
            HourglassWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Upcoming Event")
        .description("Displays the next upcomong event in Hourglass.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HourglassWidgetEntryView(entry: HourglassWidget.placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice("iPhone 11 Pro")
        }
    }
}

extension Date {
    static func +(_ date: Self, _ component: Calendar.Component) -> Date {
        date + (component, 1)
    }
    
    static func +(_ date: Self, _ tuple: (Calendar.Component, Int)) -> Date {
        Calendar.current.date(byAdding: tuple.0, value: tuple.1, to: date)!
    }
}

extension Calendar.Component {
    static func *(_ component: Self, _ multiplier: Int) -> (Self, Int) {
        (component, multiplier)
    }
}

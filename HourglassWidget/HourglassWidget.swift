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
    @FetchRequest(fetchRequest: DataProvider.allEventsFetchRequest()) var events: FetchedResults<Event>
    
    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let date = Date()
        
        let event = events.first ?? Event(
            "---------",
            range: DateInterval(start: Date(), duration: .oneDay),
            theme: 0
        )
    
        let entry = SimpleEntry(date: date, event: event)
        completion(entry)
    }
    
    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 1, to: date)!

        var entry: SimpleEntry?
        if let event = events.first {
            entry = SimpleEntry(date: date, event: event)
        }

        let timeline = Timeline(entries: entry == nil ? [] : [entry!], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let event: Event
}

struct PlaceholderView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
        
    var body: some View {
        EmptyView()
//        WidgetCardView(event: Event(
//            "---------",
//            range: DateInterval(start: .init(), duration: .oneDay),
//            theme: 0
//        ))
    }
}

struct HourglassWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let event: Event
    
    var body: some View {
        EmptyView()
    }
}

@main
struct HourglassWidget: Widget {
    private let kind: String = "HourglassWidget"
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider(),
            placeholder: PlaceholderView()
        ) { entry in
            HourglassWidgetEntryView(event: entry.event)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice("iPhone 11 Pro")
        }
    }
}

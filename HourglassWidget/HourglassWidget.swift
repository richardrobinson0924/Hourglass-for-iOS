//
//  HourglassWidget.swift
//  HourglassWidget
//
//  Created by Richard Robinson on 2020-07-03.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    public func snapshot(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let date = Date()
        
        let event = context.isPreview
            ? Event(
                name: "My Birthday",
                start: date,
                end: date.addingTimeInterval(172800),
                gradientIndex: 0
            ) : Event(
                name: configuration.eventName!,
                start: date,
                end: configuration.endDate!.date!,
                gradientIndex: 0
            )
        
        let entry = SimpleEntry(date: date, event: event)
        completion(entry)
    }
    
    public func timeline(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        
        let event = Event(
            name: configuration.eventName!,
            start: date,
            end: configuration.endDate!.date!,
            gradientIndex: 0
        )
        
        let entry = SimpleEntry(date: date, event: event)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let event: Event
}

struct PlaceholderView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let event = Event(
        name: "My Birthday",
        start: Date(),
        end: Date().addingTimeInterval(172800),
        gradientIndex: 6
    )
    
    var body: some View {
        CardView(event: event)
    }
}

struct HourglassWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        CardView(event: entry.event)
    }
}

@main
struct HourglassWidget: Widget {
    private let kind: String = "HourglassWidget"
    
    public var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider(),
            placeholder: PlaceholderView()
        ) { entry in
            HourglassWidgetEntryView(entry: entry)
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
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

//
//  HourglassWidget.swift
//  HourglassWidget
//
//  Created by Richard Robinson on 2020-07-03.
//

import WidgetKit
import SwiftUI
import Intents


struct WidgetCardView: View {
    @State var event: Event
    let radius: CGFloat = 20
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df
    }()
    
    var countdownString: String {
        if (Date() >= event.end) {
            return "Complete!"
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = event.timeRemaining > 86400 ? [.day] : [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .default
        formatter.unitsStyle = event.timeRemaining > 86400 ? .full : .positional
        
        return formatter.string(from: event.timeRemaining)!
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(event.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)

                    Text(dateFormatter.string(from: event.end))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white.opacity(0.75))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()

            Text(event.end, style: .relative)
                .font(
                    Font.system(.title3, design: .rounded)
                    //Font.system(.title, design: .rounded)
                        .monospacedDigit()
                        .weight(.bold)
                )
                .bold()
                .foregroundColor(.white)
                .padding(.bottom, 11.0)
            
            Spacer()

            ProgressView2(value: event.progress)
                .accentColor(
                    .white
                )
                //.blendMode(.overlay)
                .blendMode(.plusLighter)
        }
        .padding(.vertical, 18)
        .padding(.horizontal)
        .background(
            event.timeRemaining <= 0 ? AnyView(Color.green) : AnyView(LinearGradient(
                gradient: event.gradient,
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            ))
        )
        .accessibility(label: Text("\(event.name) event card."))
        .accessibility(value: Text("\(countdownString) remaining"))
    }
}

struct Provider: TimelineProvider {
    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let date = Date()
        
        let event = context.isPreview
            ? Event(
                name: "My Birthday",
                start: date,
                end: date.addingTimeInterval(172800),
                gradientIndex: 0
            ) : Model.shared.events.first!
        
        let entry = SimpleEntry(date: date, event: event)
        completion(entry)
    }
    
    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 1, to: date)!
        
        var entry: SimpleEntry?
        if let event = Model.shared.events.first {
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
    let event = Event(
        name: "----------",
        start: Date(),
        end: Date().addingTimeInterval(86400),
        gradientIndex: 6
    )
    
    var body: some View {
        WidgetCardView(event: event)
    }
}

struct HourglassWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let event: Event
    
    var body: some View {
        SmallCardView(event: event)
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

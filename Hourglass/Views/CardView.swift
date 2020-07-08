//
//  CardView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI

struct SmallCardView: View {
    @State var event: Event
    
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

            Text(countdownString)
                .font(
                    Font.system(size: 26, design: .rounded)
                    //Font.system(.title, design: .rounded)
                        .monospacedDigit()
                        .weight(.bold)
                )
                .bold()
                .foregroundColor(.white)
                .padding(.bottom, 11.0)
            
            Spacer()
            
            ProgressView(value: event.progress)
                .accentColor(
                    .white
                )
                //.blendMode(.overlay)
                .blendMode(.plusLighter)
        }
        .padding(.vertical, 23.0)
        .padding(.horizontal, 19.0)
        .frame(height: .cardHeight)
        .background(
            event.timeRemaining <= 0 ? AnyView(Color.green) : AnyView(LinearGradient(
                gradient: event.gradient,
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            ))
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .cornerRadius(16)
        .accessibility(label: Text("\(event.name) event card."))
        .accessibility(value: Text("\(countdownString) remaining"))
    }
}

struct CardView_Previews: PreviewProvider {    
    static var previews: some View {
        SmallCardView(event: Event(
            name: "My Birthday",
            start: .init(timeIntervalSinceNow: -40000),
            end: .init(timeIntervalSinceNow: -1),
            gradientIndex: 0
        )).previewDevice("iPhone 11 Pro").padding(.horizontal, 16).frame(width: 200)
    }
}

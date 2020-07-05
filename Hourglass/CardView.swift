//
//  CardView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI

extension UIColor {
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

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
    
    func getProgress() -> Double {
        let progress = event.progress
        return 0...1 ~= progress ? 1 - progress : 1
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(event.name)
                        .font(.title2)
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
                    Font.system(.title, design: .rounded)
                        .monospacedDigit()
                )
                .bold()
                .foregroundColor(.white)
            
            ProgressView(value: getProgress())
                .accentColor(
                    .white
                )
                //.blendMode(.overlay)
                .blendMode(.plusLighter)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 19.0)
        .frame(height: 140)
        .background(
            LinearGradient(
                gradient: event.gradient,
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .cornerRadius(16)
    }
}

struct CardView_Previews: PreviewProvider {    
    static var previews: some View {
        SmallCardView(event: Event(
            name: "My Birthday",
            start: .init(),
            end: .init(timeIntervalSinceNow: 1086400),
            gradientIndex: 0
        )).padding(.horizontal, 16).frame(width: 250)
    }
}

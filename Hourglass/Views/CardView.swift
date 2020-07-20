//
//  CardView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI

/// An implementation of `ProgressView` built in SwiftUI
struct ProgressView2<Progress>: View where Progress: BinaryFloatingPoint {
    var value: Progress
    var color: Color = .white
 
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundColor(.white)
                    .opacity(0.2)
                
                Capsule()
                    .foregroundColor(color.scaled(brightness: 2))
                    .frame(width: geometry.size.width * CGFloat(value))
            }
        }
        .frame(height: 4)
    }
}

extension DateInterval {
    var progress: Double {
        let value = 1 - end.timeIntervalSinceNow / duration
        return 0...1 ~= value ? value : 1
    }
}

struct SmallCardView: View {
    let name: String
    let range: DateInterval
    let gradient: Gradient

    var responsiveGradient: Gradient {
        range.progress >= 1.0 ? .init(colors: [.green]) : gradient
    }
        
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.doesRelativeDateFormatting = true
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    
    let dateComponentsFormatter: DateComponentsFormatter = {
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.day, .hour, .minute, .second]
        dcf.unitsStyle = .short
        dcf.maximumUnitCount = 2
        return dcf
    }()
        
    var mainText: Text {
        #if WIDGET
        let text = Text(range.end, style: .relative)
        #else
        let text = Text(
            dateComponentsFormatter.string(from: range.end.timeIntervalSinceNow)!
        )
        #endif
        
        return range.progress < 1.0 ? text : Text("Complete!")
    }
    
    var shape: some Shape {
        #if WIDGET
        return Rectangle()
        #else
        return RoundedRectangle(cornerRadius: 24.0, style: .continuous)
        #endif
    }

    var body: some View {
        shape.fill(
            LinearGradient(
                gradient: responsiveGradient,
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        )
        .overlay(
            VStack {
                VStack {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
                        .padding(.bottom, 2)

                    Text(dateFormatter.string(from: range.end))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white.opacity(0.75))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                mainText.font(
                    Font.system(.title3, design: .rounded)
                        .monospacedDigit()
                        .weight(.bold)
                )
                .tracking(-0.1)
                .foregroundColor(.white)
                .padding(.bottom, 11.0)
        
                Spacer()

                ProgressView2(value: range.progress, color: responsiveGradient.stops[0].color)
            }
            .padding(.vertical, 25)
            .padding(.horizontal)
        )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallCardView(
                name: "My Birthday",
                range: DateInterval(start: .now, duration: 33 * 60 + 33 + 1),
                gradient: Gradient.all[10]
            )
            .previewLayout(.fixed(width: 170, height: 170))
        }
    }
}

extension TimeInterval {
    /// The `TimeInterval` representing one day (86,400 seconds)
    static let oneDay: TimeInterval = 86400
}

public extension Color {
    var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)? {
        var H: CGFloat = 0, S: CGFloat = 0, B: CGFloat = 0, A: CGFloat = 0
        let uiColor = UIColor(self)
        
        if uiColor.getHue(&H, saturation: &S, brightness: &B, alpha: &A) {
            return (H, S, B, A)
        }
        
        return nil
    }
    
    func scaled(hue: Double = 1.0, saturation: Double = 1.0, brightness: Double = 1.0) -> Color {
        guard let (h, s, b, a) = self.hsba else {
            return self
        }
                
        return Color(
            hue: Double(h) * hue,
            saturation: Double(s) * saturation,
            brightness: Double(b) * brightness,
            opacity: Double(a)
        )
    }
}

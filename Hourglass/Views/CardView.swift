//
//  CardView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI

/// An implementation of `ProgressView` built in SwiftUI
struct ProgressView2<V>: View where V: BinaryFloatingPoint {
    @State private var isShowing = false
    var value: V
 
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
                
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: self.isShowing
                            ? geometry.size.width * CGFloat(self.value)
                            : 0.0)
                    .animation(.linear(duration: 0.6))
            }
            .onAppear { self.isShowing = true }
            .onChange(of: value) { precondition(0...1 ~= $0) }
            .cornerRadius(2.0)
        }
        .frame(height: 4)
    }
}

struct SmallCardView: View {
    @State var event: Event
    let radius: CGFloat = 20
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df
    }()
    
    var countdownString: String {
        if (Date() >= event.endDate!) {
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
                    Text(event.name!)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)

                    Text(dateFormatter.string(from: event.endDate!))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white.opacity(0.75))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()

            Text(countdownString)
                .font(
                    Font.system(size: 25, design: .rounded)
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
        .padding(.vertical, 22)
        .padding(.horizontal)
        .frame(height: .cardHeight)
        .background(
            event.timeRemaining <= 0 ? AnyView(Color.green) : AnyView(LinearGradient(
                gradient: event.gradient,
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            ))
        )
        .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .cornerRadius(radius)
        .shadow(color: event.gradient.stops[0].color.opacity(0.3), radius: 3, x: 0, y: 3)
        .accessibility(label: Text("\(event.name!) event card."))
        .accessibility(value: Text("\(countdownString) remaining"))
    }
}

struct CardView_Previews: PreviewProvider {
    static let event: Event = {
        let _event = Event()
        return _event
    }()
    
    static var previews: some View {
        SmallCardView(event: event).previewDevice("iPhone 11 Pro").frame(width: .cardHeight)
    }
}

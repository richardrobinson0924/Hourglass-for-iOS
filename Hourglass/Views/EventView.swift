//
//  EventView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-11.
//

import SwiftUI

struct EventView: View {
    let event: Event
    
    @State var joke: String = ""
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: event.gradient,
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
    }
    
    var countdownString: String {
        if (Date() >= event.endDate!) {
            return "Complete!"
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .default
        formatter.unitsStyle = .short
        
        return formatter.string(from: event.timeRemaining)!
            .replacingOccurrences(of: ", ", with: "\n")
            .replacingOccurrences(
                of: "(^|[^\\d])(\\d)([^\\d])",
                with: "0$2 ",
                options: .regularExpression
            )
    }
    
    var body: some View {
        HourglassView(background: gradient, progress: event.progress) {
            VStack {
                HStack {
                    Spacer()
                        .frame(width: 44, height: 44)
                    
                    Spacer()
                    
                    Text("\(event.name!)")
                        .font(Font.system(.title3).weight(.semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color.white.opacity(0.75))
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text(countdownString).font(
                    Font.system(size: 60, weight: .bold, design: .default)
                        .monospacedDigit()
                        .bold()
                )
                .foregroundColor(Color.white.opacity(0.9))
                .offset(y: -10)
                
                Spacer()
            }
        }
    }
}

struct HourglassView<Background: View, Content: View>: View {
    let gradient: Background
    let progress: CGFloat
    let content: () -> Content
    
    init<Value : BinaryFloatingPoint>(
        background: Background,
        progress: Value,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.gradient = background
        self.progress = CGFloat(progress)
        self.content = content
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Color.black

                gradient.opacity(0.2).padding(.all, 0)
                
                VStack {
                    Spacer()
                    gradient
                        .opacity(0.8)
                        .frame(height: (1 - progress) * UIScreen.main.bounds.height)
                        .padding(.all, 0)
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            content()
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static let event: Event = {
        let e = Event()
        e.name = "My Birthday"
        e.startDate = Date().addingTimeInterval(-86400)
        e.endDate = Date().addingTimeInterval(2 * 86400)
        e.colorIndex = 6
        
        return e
    }()
    
    static var previews: some View {
        EventView(event: event)
    }
}
 

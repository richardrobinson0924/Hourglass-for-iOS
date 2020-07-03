//
//  ProgressView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI

/// Produces a `View` of a circular progress bar with a filled gradient stroke, with the given `progress`
/// represented by a percentage number inside of the circle
///
///     @State var progress: Double = 0.0
///     // ...
///     VStack {
///         // every time this button is pressed, the bar animates between 0% and 73% filled
///         Button("Press") {
///             withAnimation(.easeInOut(duration: 1.0)) {
///                 self.progress = 0.73 - self.progress
///             }
///         }
///
///         ProgressView(
///             progress: progress,
///             diameter: 70,
///             lineWidth: 8,
///             gradient: Gradient(colors: [.red, .blue])
///         ).font(
///             Font.subheadline.bold().monospacedDigit()
///         )
///     }
///
/// - Parameters:
///     - diameter the width and height of the View
///     - lineWidth the width (thickness) of the stroke
///     - gradient the gradient to fill the stroke of the progress bar
public struct RingView: View {
    struct Properties {
        var progress: Double
        
        let diameter: CGFloat
        let colors: (start: Color, end: Color)
        
        func multiplier() -> CGFloat {
            diameter / 44
        }
    }
    
    let props: Properties
    
    init(_ properties: Properties) {
        self.props = properties
    }

    public var body: some View {
        return Circle()
            .stroke(
                Color.black.opacity(0.1),
                style: StrokeStyle(lineWidth: 5 * props.multiplier())
            )
            .frame(width: props.diameter, height: props.diameter)
            .modifier(ProgressAnimatableModifier(props: props))
    }
}


struct ProgressAnimatableModifier: AnimatableModifier {
    var animatableData: Double {
        get { props.progress }
        set { props.progress = newValue }
    }

    var props: RingView.Properties
    
    func body(content: Content) -> some View {
        let circle = Circle()
            .trim(from: 1 - CGFloat(props.progress), to: 1)
            .stroke(
                LinearGradient(
                    gradient: Gradient(
                        colors: [props.colors.start, props.colors.end]
                    ),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                ),
                style: StrokeStyle(
                    lineWidth: 5 * props.multiplier(),
                    lineCap: .round,
                    lineJoin: .round,
                    miterLimit: .infinity,
                    dash: [20, 0],
                    dashPhase: 0
                )
            )
            .rotationEffect(Angle(degrees: 90))
            .rotation3DEffect(
                Angle(degrees: 180),
                axis: (x: 1, y: 0, z: 0)
            )
            .frame(width: props.diameter, height: props.diameter)
            .shadow(
                color: props.colors.end.opacity(0.1),
                radius: 3 * props.multiplier(), x: 0, y: 3 * props.multiplier()
            )
        
        let text = Text(String(format: "%.0f%%", props.progress * 100))
            .font(
                Font.system(
                    size: 12 * props.multiplier(),
                    design: .rounded
                )
                .bold()
                .monospacedDigit()
            )
            .foregroundColor(.white)
        
        return content.overlay(circle).overlay(text)
     }
}

struct ProgressView_Previews: PreviewProvider {
    @State static var progress: Double = 0.73
    
    static var previews: some View {
        RingView(.init(
            progress: progress,
            diameter: 70,
            colors: (start: .red, end: .blue)
        ))
    }
}

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
public struct ProgressView: View {
    struct Properties {
        var progress: Double
        let diameter: CGFloat
        let lineWidth: CGFloat
        let gradient: Gradient
    }
    
    let props: Properties
    
    init(_ properties: Properties) {
        self.props = properties
    }

    public var body: some View {
        return Circle()
            .stroke(
                Color.black.opacity(0.1),
                style: StrokeStyle(lineWidth: props.lineWidth)
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

    var props: ProgressView.Properties
    
    func body(content: Content) -> some View {
        let circle = Circle()
            .trim(from: 1 - CGFloat(props.progress), to: 1)
            .stroke(
                LinearGradient(
                    gradient: props.gradient,
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                ),
                style: StrokeStyle(
                    lineWidth: props.lineWidth,
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
                color: props.gradient.stops.last!.color.opacity(0.1),
                radius: 3, x: 0, y: 3
            )
        
        let text = Text(String(format: "%.0f%%", props.progress * 100))
        
        return content.overlay(circle).overlay(text)
     }
}

struct ProgressView_Previews: PreviewProvider {
    @State static var progress: Double = 0.73
    
    static var previews: some View {
        ProgressView(.init(
            progress: progress,
            diameter: 70,
            lineWidth: 8,
            gradient: Gradient(colors: [.red, .blue])
        )).font(
            Font.subheadline.bold().monospacedDigit()
        )
    }
}

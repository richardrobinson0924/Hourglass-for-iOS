//
//  ContentView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import SwiftUI


struct ContentView: View {
    @State var progress: Double = 0.0

    var body: some View {
        VStack {
            Button("Press") {
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.progress = 0.73 - self.progress
                }
            }
            
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11 Pro")
    }
}

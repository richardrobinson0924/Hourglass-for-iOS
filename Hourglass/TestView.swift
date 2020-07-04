//
//  TestView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-04.
//

import SwiftUI

struct TestView: View {
    @State var isPresenting = false
    @State var isFullscreen = false
    @State var sourceRect: CGRect? = nil

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Button(action: {
                    self.isFullscreen = false
                    self.isPresenting = true
                    self.sourceRect = proxy.frame(in: .global)
                }) {
                    Rectangle().frame(width: 200, height: 300)
                }
            }

            if isPresenting {
                GeometryReader { proxy in
                    Rectangle().frame(width: 300, height: 300)
                    .frame(
                        width: self.isFullscreen ? nil : self.sourceRect?.width ?? nil,
                        height: self.isFullscreen ? nil : self.sourceRect?.height ?? nil)
                    .position(
                        self.isFullscreen ? proxy.frame(in: .global).center :
                            self.sourceRect?.center ?? proxy.frame(in: .global).center)
                    .onAppear {
                        withAnimation {
                            self.isFullscreen = true
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

extension CGRect {
    var center : CGPoint {
        return CGPoint(x:self.midX, y:self.midY)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

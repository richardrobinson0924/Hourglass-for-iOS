//
//  AddEventButtonView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-04.
//

import SwiftUI

struct AddEventButtonView: View {
    var namespace: Namespace.ID
    
    let action: () -> Void

    var body: some View {
        Image(systemName: "calendar.badge.plus")
            .renderingMode(.original)
            .scaleEffect(1.75)
            .frame(height: .cardHeight)
            .frame(maxWidth: .infinity)
            .background(
                Color.black.opacity(0.01)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.blue, lineWidth: 3)
            )
            .animation(.linear(duration: 0.1))
            .onTapGesture {
                withAnimation {
                    action()
                }
            }
            .matchedGeometryEffect(id: "-1", in: namespace, isSource: false)
    }
}

struct AddEventButtonView_Previews: PreviewProvider {
    @State static var showModal = false
    
    @Namespace static var namespace
    
    static var previews: some View {
        AddEventButtonView(namespace: namespace) { }
    }
}

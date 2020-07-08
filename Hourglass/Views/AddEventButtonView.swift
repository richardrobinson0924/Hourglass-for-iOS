//
//  AddEventButtonView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-04.
//

import SwiftUI

struct AddEventButtonView: View {
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
    }
}

struct AddEventButtonView_Previews: PreviewProvider {
    @State static var showModal = false
        
    static var previews: some View {
        AddEventButtonView() { }
    }
}

//
//  AddEventButtonView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-04.
//

import SwiftUI

struct AddEventButtonView: View {
    @Binding var editMode: Bool
    @Binding var showModal: Bool
    
    var namespace: Namespace.ID

    var body: some View {
        Image(systemName: "calendar.badge.plus")
            .renderingMode(.original)
            .scaleEffect(1.75)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(
                Color.black.opacity(0.01)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.blue, lineWidth: 3)
            )
            .opacity(self.editMode ? 0.0 : 1.0)
            .animation(.linear(duration: 0.1))
            .onTapGesture {
                withAnimation {
                    self.showModal = true
                }
            }
            .matchedGeometryEffect(id: "box", in: namespace, isSource: false)
    }
}

struct AddEventButtonView_Previews: PreviewProvider {
    @State static var editMode = false
    @State static var showModal = false
    
    @Namespace static var namespace

    
    static var previews: some View {
        AddEventButtonView(editMode: $editMode, showModal: $showModal, namespace: namespace)
    }
}

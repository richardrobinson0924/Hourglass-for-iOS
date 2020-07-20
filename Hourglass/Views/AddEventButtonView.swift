//
//  AddEventButtonView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-04.
//

import SwiftUI

struct AddEventButtonView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24.0, style: .continuous)
            .stroke(Color.blue, lineWidth: 3.0)
            .overlay(
                Image(systemName: "hourglass.badge.plus")
                    .renderingMode(.original)
                    .imageScale(.large)
                    .scaleEffect(1.3)
            )
            .aspectRatio(1.0, contentMode: .fill)
    }
}

struct AddEventButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventButtonView()
            .previewLayout(.fixed(width: 155, height: 155))
    }
}

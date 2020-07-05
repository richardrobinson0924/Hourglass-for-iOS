//
//  TestView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-04.
//

import SwiftUI

struct TestView: View {
    @State var idx: Int = 0

    var body: some View {
        Picker(selection: $idx, label: Text("Picker")) {
            ForEach(0..<5) { i in
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .tag(i)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView().padding(.horizontal, 100)
    }
}

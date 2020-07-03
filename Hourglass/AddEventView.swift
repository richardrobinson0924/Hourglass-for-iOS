//
//  AddEventView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-03.
//

import SwiftUI

struct AddEventView: View {
    @State var username: String = ""
    @State var wakeUp = Date()
    @State var color: Color = Color.blue

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("INFORMATION")) {
                    TextField("Event Name", text: $username)
                    DatePicker(
                        "Date of Event".padding(toLength: 28, withPad: " ", startingAt: 0),
                        selection: $wakeUp,
                        in: Date()...
                    )
                    ColorPicker("Select a Color", selection: $color, supportsOpacity: false)
                }
            }
            .navigationBarTitle("Add Event")
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}

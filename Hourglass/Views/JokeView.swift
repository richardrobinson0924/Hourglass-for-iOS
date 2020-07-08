//
//  JokeView.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-07.
//

import SwiftUI

struct JokeView: View {
    @State var text: String = ""
    
    var body: some View {
        Group {
            Text(text)
        }.onAppear {
            Joke.getJokeOfTheDay { joke, error in
                guard error == nil else {
                    self.text = (error?.localizedDescription ?? "q")
                    return
                }
                
                self.text = joke?.text?.replacingOccurrences(of: "\r\n", with: " ") ?? "aaa"
            }
        }
    }
}

struct JokeView_Previews: PreviewProvider {
    static var previews: some View {
        JokeView()
    }
}

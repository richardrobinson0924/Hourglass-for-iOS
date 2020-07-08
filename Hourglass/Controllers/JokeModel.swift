//
//  JokeModel.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-06.
//

import Foundation

struct Joke : Codable {
    let title: String?
    let length: String?
    let clean: String?
    let racial: String?
    let date: String?
    let id: String?
    let text: String?
    
    static func getJokeOfTheDay(_ completionHandler: @escaping (Joke?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.jokes.one/jod")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil,
                  let data = data
            else {
                completionHandler(nil, error)
                return
            }
            
            let jokeModel = try! JSONDecoder().decode(JokeModel.self, from: data)
            
            let joke = jokeModel.contents.jokes[0].joke
            completionHandler(joke, nil)
        }).resume()
    }
}

struct JokeDescription : Codable {
    let category: String?
    let title: String?
    let description: String?
    let language: String?
    let background: String?
    let date: String?
    let joke: Joke
}

struct JokeModel : Codable {
    struct Contents : Codable {
        let jokes: [JokeDescription]
        let copyright: String?
    }

    struct Success : Codable {
        let total: Int?
    }
    
    let success: Success
    let contents: Contents
}

//
//  JokeModel.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-06.
//

import Foundation

// {"id":131,"type":"general","setup":"How do you organize a space party?","punchline":"You planet."}
struct Pun : Codable {
    enum HTTPError: Error {
        case response(String)
    }
    
    let type: String
    let setup: String
    let punchline: String
    let id: Int

    var text: String {
        "\(setup) \(punchline)"
    }
    
    static func fetchPun(_ completion: @escaping (Result<Pun, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://official-joke-api.appspot.com/random_joke")!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                completion(.failure(error ?? HTTPError.response(response?.description ?? "")))
                return
            }
            
            let pun = try! JSONDecoder().decode(Pun.self, from: data)
            completion(.success(pun))
        }
    }
}

struct Joke : Codable {
    enum FetchError: Error {
        case couldNotFetchJokeError
    }
    
    let title: String?
    let length: String?
    let clean: String?
    let racial: String?
    let date: String?
    let id: String?
    let text: String?
    
    static func getJokeOfTheDay(_ completionHandler: @escaping (Result<Joke, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.jokes.one/jod")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil, let data = data
            else {
                completionHandler(.failure(error ?? FetchError.couldNotFetchJokeError))
                return
            }
            
            let jokeModel = try! JSONDecoder().decode(JokeModel.self, from: data)
            
            let joke = jokeModel.contents.jokes[0].joke
            completionHandler(.success(joke))
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

//
//  Event.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import Foundation


struct Event : Codable {
    let name: String
    let start: Date
    let end: Date
    let colorCode: Int
    
    var timeRemaining: TimeInterval {
        get { end.timeIntervalSinceNow }
    }
    
    lazy var totalTime: TimeInterval = end.timeIntervalSince(start)
}

enum SortField : String, Codable {
    case end = "End Date"
    case timeRemaining = "Remaining Time"
}

enum FontStyle : String, Codable {
    case apple
    case openDyslexic
}

struct Model : Codable {
    var sortField: SortField = .timeRemaining
    var font: FontStyle = .apple
    var events: [Event] = []
    
    static let key = "hourglass_model"
    
    static var shared: Model = {
        let data = UserDefaults.standard.data(forKey: key)
        
        if let data = data {
            return try! JSONDecoder().decode(Model.self, from: data)
        } else {
            return Model()
        }
    }()
    
    static func save() {
        UserDefaults.standard.set(shared, forKey: key)
    }
}

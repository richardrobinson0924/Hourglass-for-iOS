//
//  Event.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import Foundation
import SwiftUI

public extension CGFloat {
    static let cardHeight: CGFloat = 140
}

public struct Event : Codable, Hashable, Equatable {
    let name: String
    let start: Date
    let end: Date
    let gradientIndex: Int
    
    var gradient: Gradient {
        Gradient.gradients[gradientIndex]
    }
    
    var timeRemaining: TimeInterval {
        end.timeIntervalSinceNow
    }
    
    var progress: Double {
        get { end.timeIntervalSinceNow / end.timeIntervalSince(start) }
    }    
}

class Model : Codable, ObservableObject {
    private enum CodingKeys : String, CodingKey {
        case events
        case sortedKey
    }
    
    @Published var _events: [Event] = []
    
    var events: [Event] {
        get { _events }
        set(newValue) {
            _events = newValue.sorted(by: Model.SortableKeyPaths[sortedKey]!)
            save()
        }
    }
    
    @Published var _sortedKey: String = SortableKeyPaths.keys.first!
    
    var sortedKey: String {
        get { _sortedKey }
        set(newValue) {
            _events.sort(by: Model.SortableKeyPaths[newValue]!)
            save()
        }
    }
    
    init(events: [Event] = []) {
        self.events = events
    }
    
    required init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        let events = try? container?.decode([Event].self, forKey: .events)
        let sortKey = try? container?.decode(String.self, forKey: .sortedKey)
        
        self.events = events ?? []
        self.sortedKey = sortKey ?? Model.SortableKeyPaths.keys.first!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try! container.encode(events, forKey: .events)
        try! container.encode(sortedKey, forKey: .sortedKey)
    }
}

extension Model {
    private static let key = "hourglass_model"
    
    static let SortableKeyPaths: [String : (Event, Event) -> Bool] = [
        "Event End Date" : { $0.end < $1.end },
        "Date Added" : { $0.start < $1.start }
    ]
    
    static var shared: Model {
        let data = UserDefaults.standard.data(forKey: key)
        
        if let data = data {
            return try! JSONDecoder().decode(Model.self, from: data)
        } else {
            return Model()
        }
    }
}

extension Model {
    func addEvent(_ event: Event) {
        self.events.append(event)
    }
    
    func removeEvent(_ event: Event?) {
        self.events.removeAll(where: { $0 == event })
    }
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: Model.key)
    }
}

extension Gradient {
    static let gradients = [
        [#colorLiteral(red: 0.9654200673, green: 0.1590853035, blue: 0.2688751221, alpha: 1),#colorLiteral(red: 0.7559037805, green: 0.1139892414, blue: 0.1577021778, alpha: 1)],
        [#colorLiteral(red: 0.9338900447, green: 0.4315618277, blue: 0.2564975619, alpha: 1),#colorLiteral(red: 0.8518816233, green: 0.1738803983, blue: 0.01849062555, alpha: 1)],
        [#colorLiteral(red: 0.9953531623, green: 0.54947716, blue: 0.1281470656, alpha: 1),#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1)],
        [#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1),#colorLiteral(red: 0.8931249976, green: 0.5340107679, blue: 0.08877573162, alpha: 1)],
        [#colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1),#colorLiteral(red: 0.2060100436, green: 0.6006633639, blue: 0.09944178909, alpha: 1)],
        [#colorLiteral(red: 0.2761503458, green: 0.824685812, blue: 0.7065336704, alpha: 1),#colorLiteral(red: 0, green: 0.6422213912, blue: 0.568986237, alpha: 1)],
        [#colorLiteral(red: 0.2494148612, green: 0.8105323911, blue: 0.8425348401, alpha: 1),#colorLiteral(red: 0, green: 0.6073564887, blue: 0.7661359906, alpha: 1)],
        [#colorLiteral(red: 0.3045541644, green: 0.6749247313, blue: 0.9517192245, alpha: 1),#colorLiteral(red: 0.008423916064, green: 0.4699558616, blue: 0.882807076, alpha: 1)],
        [#colorLiteral(red: 0.1774400771, green: 0.466574192, blue: 0.8732826114, alpha: 1),#colorLiteral(red: 0.00491155684, green: 0.287129879, blue: 0.7411141396, alpha: 1)],
        [#colorLiteral(red: 0.4613699913, green: 0.3118675947, blue: 0.8906354308, alpha: 1),#colorLiteral(red: 0.3018293083, green: 0.1458326578, blue: 0.7334778905, alpha: 1)],
        [#colorLiteral(red: 0.7080290914, green: 0.3073516488, blue: 0.8653779626, alpha: 1),#colorLiteral(red: 0.5031493902, green: 0.1100070402, blue: 0.6790940762, alpha: 1)],
        [#colorLiteral(red: 0.9495453238, green: 0.4185881019, blue: 0.6859942079, alpha: 1),#colorLiteral(red: 0.8123683333, green: 0.1657164991, blue: 0.5003474355, alpha: 1)],
    ].map { uiColorPair in
        Gradient(colors: uiColorPair.map { Color($0) })
    }
}

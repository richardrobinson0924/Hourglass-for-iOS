//
//  Event.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-02.
//

import Foundation
import SwiftUI
import EventKit
import WidgetKit
import Intents
import CoreData

public extension CGFloat {
    static let cardHeight: CGFloat = 155
}

extension Date {
    static var now: Date { Date() }
}

class UserNotifications {
    static let shared = UserNotifications()
    
    private let center = UNUserNotificationCenter.current()
    
    func unregisterEventNotification(_ event: Event) {
        self.center.removePendingNotificationRequests(
            withIdentifiers: ["\(event.hashValue)"]
        )
    }
    
    func registerEventNotification(_ event: Event) {
        self.center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            guard granted, error == nil else {
                print(error?.localizedDescription ?? "notification permissions not granted")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Countdown complete!"
            content.body = "The countdown to \(event.name!) is complete! 🎉"
            content.categoryIdentifier = "countdown"
            content.sound = UNNotificationSound(
                named: UNNotificationSoundName(rawValue: "Success 1.caf")
            )
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: event.endDate!
                ),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "\(event.hashValue)",
                content: content,
                trigger: trigger
            )
            
            self.center.add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

public class UserCalendar {
    enum PermissionError : Error {
        case permissionDenied
    }
    
    static let shared = UserCalendar()
    
    private let store = EKEventStore()
    
    private func toEventKitEvent(_ event: Event) -> EKEvent {
        let calendarEvent = EKEvent(eventStore: self.store)
        calendarEvent.title = event.name
        calendarEvent.startDate = event.endDate!
        calendarEvent.endDate = event.endDate!.addingTimeInterval(3600)
        calendarEvent.calendar = self.store.defaultCalendarForNewEvents
        
        return calendarEvent
    }
    
    func removeEvent(_ event: Event, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            completion(.success(false))
            return
        }
        
        let calendarEvent = toEventKitEvent(event)
        
        do {
            try self.store.remove(calendarEvent, span: .thisEvent)
            completion(.success(true))
        } catch let error {
            completion(.failure(error))
        }
    }
    

    func addEvent(_ event: Event, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let addEventAction: () -> Void = {
            let calendarEvent = self.toEventKitEvent(event)
            
            do {
                try self.store.save(calendarEvent, span: .thisEvent)
                completion(.success(true))
            } catch let error {
                completion(.failure(error))
            }
        }
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .denied, .restricted:
            completion(.success(false))
            
        case .authorized:
            addEventAction()
            
        case .notDetermined:
            self.store.requestAccess(to: .event) { (granted, error) in
                if granted && error == nil {
                    addEventAction()
                }
                completion(.failure(error ?? PermissionError.permissionDenied))
            }
            
        default:
            completion(.success(false))
        }
    }
}

extension Event {
    var gradient: Gradient {
        Gradient.gradients[Int(colorIndex)]
    }
    
    var timeRemaining: TimeInterval {
        endDate!.timeIntervalSinceNow
    }
    
    var progress: Double {
        let value = 1 - endDate!.timeIntervalSinceNow / endDate!.timeIntervalSince(startDate!)
        return 0...1 ~= value ? value : 1
    }
}

extension Event : Identifiable {}

class DataProvider {
    static let shared = DataProvider()
    
    static func allEventsFetchRequest() -> NSFetchRequest<Event> {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Defaults.shared.comparatorKey, ascending: true)]
        return request
    }
    
    func addEvent(in context: NSManagedObjectContext, name: String, range: ClosedRange<Date>, colorIndex: Int, shouldAddToCalendar inCalendar: Bool) {
        let event = Event(context: context)
        event.name = name
        event.startDate = range.lowerBound
        event.endDate = range.upperBound
        event.colorIndex = Int64(colorIndex)
        event.id = UUID()
        
        UserNotifications.shared.registerEventNotification(event)
        if inCalendar {
            UserCalendar.shared.addEvent(event) { _ in }
        }
    }
    
    func removeEvent(_ event: Event?, from context: NSManagedObjectContext) {
        guard let event = event else { return }
        
        context.delete(event)
        
        UserNotifications.shared.unregisterEventNotification(event)
        UserCalendar.shared.removeEvent(event) { _ in }
    }
}

struct Defaults : Codable {
    static let comparators: [String: String] = [
        "Event Date" : "endDate",
        "Event Name" : "name",
        "Time Remaining" : "progress"
    ]
    
    var comparatorKey: String = Defaults.comparators["Event Date"]! {
        didSet {
            save()
        }
    }
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        UserDefaults(suiteName: "group.hourglass")?.set(data, forKey: "hourglass.defaults")
    }
    
    static var shared: Defaults {
        let data = UserDefaults(suiteName: "group.hourglass")?.data(forKey: "hourglass.defaults")
        
        if let data = data {
            return try! JSONDecoder().decode(Defaults.self, from: data)
        } else {
            return Defaults()
        }
    }
}

public extension Gradient {
    static let gradients = [
        [#colorLiteral(red: 0.9654200673, green: 0.1590853035, blue: 0.2688751221, alpha: 1),#colorLiteral(red: 0.7559037805, green: 0.1139892414, blue: 0.1577021778, alpha: 1)], // red
        [#colorLiteral(red: 0.9338900447, green: 0.4315618277, blue: 0.2564975619, alpha: 1),#colorLiteral(red: 0.8518816233, green: 0.1738803983, blue: 0.01849062555, alpha: 1)], // deep orange
        [#colorLiteral(red: 0.9953531623, green: 0.54947716, blue: 0.1281470656, alpha: 1),#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1)], // orange
        [#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1),#colorLiteral(red: 0.8931249976, green: 0.5340107679, blue: 0.08877573162, alpha: 1)], // yellow
        [#colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1),#colorLiteral(red: 0.2060100436, green: 0.6006633639, blue: 0.09944178909, alpha: 1)], // green
        [#colorLiteral(red: 0.2761503458, green: 0.824685812, blue: 0.7065336704, alpha: 1),#colorLiteral(red: 0, green: 0.6422213912, blue: 0.568986237, alpha: 1)], // teal
        [#colorLiteral(red: 0.2494148612, green: 0.8105323911, blue: 0.8425348401, alpha: 1),#colorLiteral(red: 0, green: 0.6073564887, blue: 0.7661359906, alpha: 1)], // light blue
        [#colorLiteral(red: 0.3045541644, green: 0.6749247313, blue: 0.9517192245, alpha: 1),#colorLiteral(red: 0.008423916064, green: 0.4699558616, blue: 0.882807076, alpha: 1)], // sky blue
        [#colorLiteral(red: 0.1774400771, green: 0.466574192, blue: 0.8732826114, alpha: 1),#colorLiteral(red: 0.00491155684, green: 0.287129879, blue: 0.7411141396, alpha: 1)], // blue
        [#colorLiteral(red: 0.4613699913, green: 0.3118675947, blue: 0.8906354308, alpha: 1),#colorLiteral(red: 0.3018293083, green: 0.1458326578, blue: 0.7334778905, alpha: 1)], // indigo
        [#colorLiteral(red: 0.7080290914, green: 0.3073516488, blue: 0.8653779626, alpha: 1),#colorLiteral(red: 0.5031493902, green: 0.1100070402, blue: 0.6790940762, alpha: 1)], // purple
        [#colorLiteral(red: 0.9495453238, green: 0.4185881019, blue: 0.6859942079, alpha: 1),#colorLiteral(red: 0.8123683333, green: 0.1657164991, blue: 0.5003474355, alpha: 1)], // pink
    ].map { uiColorPair in
        Gradient(colors: uiColorPair.map { Color($0) })
    }
}

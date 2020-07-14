//
//  IntentHandler.swift
//  AddEventIntent
//
//  Created by Richard Robinson on 2020-07-10.
//

import Intents

class IntentHandler: INExtension, AddEventIntentHandling {
    func resolveAddToCalendar(for intent: AddEventIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        if let addToCalendar = intent.addToCalendar {
            completion(.success(with: Bool(truncating: addToCalendar)))
        } else {
            completion(.success(with: true))
        }
    }
    
    func resolveEndDate(for intent: AddEventIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        if let end = intent.endDate {
            completion(.success(with: end))
        } else {
            completion(.needsValue())
        }
    }
    
    func handle(intent: AddEventIntent, completion: @escaping (AddEventIntentResponse) -> Void) {
        guard let name = intent.eventName, let end = intent.endDate else { return }
        let event = Event(
            name: name,
            start: Date(),
            end: Calendar.current.date(from: end)!,
            gradientIndex: max(intent.color.rawValue - 1, 0)
        )
                
        Model.shared.addEvent(event) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(false):
                print("couldn't add to calendar")
                fallthrough
            default:
                completion(.success(eventName: name, endDate: end))
            }
        }
    }
    
    func resolveEventName(for intent: AddEventIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let name = intent.eventName, !name.isEmpty {
            completion(.success(with: name))
        } else {
            completion(.needsValue())
        }
    }
    
    func resolveColor(for intent: AddEventIntent, with completion: @escaping (INColorResolutionResult) -> Void) {
        completion(.success(with: intent.color))
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is AddEventIntent else { fatalError() }
        return self
    }
    
}

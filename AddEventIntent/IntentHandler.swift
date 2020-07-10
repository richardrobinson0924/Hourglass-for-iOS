//
//  IntentHandler.swift
//  AddEventIntent
//
//  Created by Richard Robinson on 2020-07-10.
//

import Intents

class IntentHandler: INExtension, AddEventIntentHandling {
    func handle(intent: AddEventIntent, completion: @escaping (AddEventIntentResponse) -> Void) {
        guard let name = intent.eventName, let end = intent.endDate else { return }
        let event = Event(
            name: name,
            start: Date(),
            end: Calendar.current.date(from: end)!,
            gradientIndex: 0
        )
        
        Model.shared.addEvent(event) { result in
            if case .success(true) = result {
                completion(.success(eventName: name, endDate: end))
            }
        }
    }
    
    func resolveEventName(for intent: AddEventIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let name = intent.eventName, !name.isEmpty, name != "My Event" {
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

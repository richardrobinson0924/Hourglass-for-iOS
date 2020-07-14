//
//  HourglassTests.swift
//  HourglassTests
//
//  Created by Richard Robinson on 2020-07-10.
//

import XCTest
@testable import Hourglass
@testable import EventKit

class HourglassTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddCalendar() throws {
        let event = Event(name: "test", start: Date(), end: Date(), gradientIndex: 0)
        XCTAssert(EKEventStore.authorizationStatus(for: .event) == .denied)
                
        UserCalendar.shared.addEvent(event) { result in
            switch result {
            case .success(_):
                XCTAssert(true)
            case .failure(let error):
                XCTAssert(false, error.localizedDescription)
            }
        }
        
    }

}

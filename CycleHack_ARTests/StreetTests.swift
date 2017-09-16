//
//  StreetTests.swift
//  CycleHack_ARTests
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import XCTest
@testable import CycleHack_AR

class StreetTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecodeStreet() {
        let jsonString = "{ \"name\": \"Alt-Heiligensee\", \"length\": 0.024733295307219308, \"count\": 2, \"count_by_length\": 80.862658014527796 }"
        let data = jsonString.data(using: .utf8)!
        let street = try! JSONDecoder().decode(Street.self, from: data)
        
        XCTAssertEqual(street.name, "Alt-Heiligensee")
        XCTAssertEqual(street.length, 0.024733295307219308)
        XCTAssertEqual(street.count, 2)
        XCTAssertEqual(street.count_by_length, 80.862658014527796)
    }
    
}

//
//  PointTests.swift
//  CycleHack_ARTests
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import XCTest
@testable import CycleHack_AR

class PointTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEncodePoint() {
        let jsonString = "{ \"name\": \"ALT-REINICKENDORF / ROEDERNALLEE / VELTENER STR.\", \"year\": 2016, \"count\": 2, \"directorate\": \"11\" }"
        let data = jsonString.data(using: .utf8)!
        let point = try! JSONDecoder().decode(Point.self, from: data)
        
        XCTAssertEqual(point.name, "ALT-REINICKENDORF / ROEDERNALLEE / VELTENER STR.")
        XCTAssertEqual(point.year, 2016)
        XCTAssertEqual(point.count, 2)
        XCTAssertEqual(point.directorate, "11")
    }
    
}

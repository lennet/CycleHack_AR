//
//  DataOverYearModel.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import UIKit

struct DataOverYearModel: Codable {
    var street: String
    var directorate: Int
    var lat: Double
    var lng: Double
    var y2008: Int
    var y2009: Int
    var y2010: Int
    var y2011: Int
    var y2012: Int
    var y2013: Int
    var y2014: Int
    var y2015: Int
    var y2016: Int
}

extension DataOverYearModel {
    
    static func getAll() -> [DataOverYearModel] {
        let path = Bundle.main.path(forResource: "years_overview", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        return try! JSONDecoder().decode([DataOverYearModel].self, from: data)
    }
    
}

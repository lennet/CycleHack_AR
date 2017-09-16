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
    var count_2008: Int
    var count_2009: Int
    var count_2010: Int
    var count_2011: Int
    var count_2012: Int
    var count_2013: Int
    var count_2014: Int
    var count_2015: Int
    var count_2016: Int
}

extension DataOverYearModel {
    
    static func getAll() -> [DataOverYearModel] {
        let path = Bundle.main.path(forResource: "years_overview", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        return try! JSONDecoder().decode([DataOverYearModel].self, from: data)
    }
    
}

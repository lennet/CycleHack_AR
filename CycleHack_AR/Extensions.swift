//
//  Extensions.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import Foundation

func ==<Element : Equatable> (lhs: [[Element]], rhs: [[Element]]) -> Bool {
    return lhs.elementsEqual(rhs, by: ==)
}

func ==<Element : Equatable> (lhs: [[[Element]]], rhs: [[[Element]]]) -> Bool {
    return lhs.elementsEqual(rhs, by: ==)
}


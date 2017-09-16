//
//  UIBezierPath+Interpolation.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import UIKit

public enum Interpolation {
    case none
    case linear
}

extension UIBezierPath {
    
    public convenience init(points: [CGPoint], interpolation: Interpolation) {
        self.init()
        switch interpolation {
        case .none:
            points.forEach {
                addLine(from: CGPoint(x: $0.x , y:0), to: $0)
            }
            break
        case .linear:
            move(to: .zero)
            points.forEach{ addLine(to: $0) }
            break
            
        }
    }
    
    public func addLine(from: CGPoint, to:CGPoint) {
        self.move(to: from)
        self.addLine(to: to)
    }
    
}

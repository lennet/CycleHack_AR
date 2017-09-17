//
//  Extensions.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import Foundation
import SceneKit

func ==<Element : Equatable> (lhs: [[Element]], rhs: [[Element]]) -> Bool {
    return lhs.elementsEqual(rhs, by: ==)
}

func ==<Element : Equatable> (lhs: [[[Element]]], rhs: [[[Element]]]) -> Bool {
    return lhs.elementsEqual(rhs, by: ==)
}

extension SCNNode {
    
    public class func graphNode(with values:[Float],for color: UIColor) -> SCNNode {
        let size = CGSize(width: 60, height: 60)
        let maxValue = values.max() ?? 0
        var points: [CGPoint] = values.enumerated().map
        {
            (index, element) in
            
            let y = (CGFloat(element) / CGFloat(maxValue) * size.height)
            let x = CGFloat(index) / CGFloat(values.count) * size.width
            
            // plus 0.01 avoids holes caused by zero values
            return CGPoint(x: x, y: y+0.01)
        }
        
        points.append(CGPoint(x: size.width, y: 0))
        points.insert(CGPoint(x: 0, y: 0), at: 0)
        
        let path = UIBezierPath(points: points, interpolation: .linear)
        
        path.close()
        let shape = SCNShape(path: path, extrusionDepth: 5)
        
        let material = SCNMaterial()
        material.diffuse.contents = color.withAlphaComponent(0.8)
        shape.materials = [material]
        
        let node = SCNNode(geometry: shape)
        return node
    }
    
}


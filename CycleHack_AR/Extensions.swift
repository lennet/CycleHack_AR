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
    
    public class func graphNode(with values:[Float],for colors: [UIColor]) -> SCNNode {
        let size = CGSize(width: 75, height: 75)
        let maxValue = values.max() ?? 0
        let node = SCNNode()
        values.enumerated().forEach{ (index, value) in
            let box = SCNBox(width: size.width/CGFloat(values.count), height: size.height * CGFloat(value/maxValue), length: 5, chamferRadius: 0)
            
            let material = SCNMaterial()
            material.diffuse.contents = colors[index]
            box.materials = [material]
            
            let boxNode = SCNNode(geometry: box)
            boxNode.position.x += Float((size.width/CGFloat(values.count)) * CGFloat(index)) + Float(size.width)/10
            boxNode.position.y += Float(size.height * CGFloat(value/maxValue))/2
            node.addChildNode(boxNode)
        }

        return node
    }
    
}


//
//  PanIndicatorView.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import UIKit

@IBDesignable
class PanIndicatorView: UIView {

    @IBInspectable
    var touchedAlpha: CGFloat = 1
    @IBInspectable
    var defaultAlpha: CGFloat = 0.75
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }

    func configure() {
        alpha = defaultAlpha
        layer.cornerRadius = 8
        layer.maskedCorners = CACornerMask.layerMinXMinYCorner.union(.layerMaxXMinYCorner)
        clipsToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = touchedAlpha
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = defaultAlpha
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        alpha = defaultAlpha
    }
    
    override func draw(_ rect: CGRect) {
        let size = CGSize(width: rect.width/2, height: rect.height/10)
        let point = CGPoint(x: (rect.width-size.width)/2, y: (rect.height-size.height)/2)
        
        let path = UIBezierPath(roundedRect: CGRect(origin: point, size: size), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 4, height: 4))
        UIColor.red.setFill()
        path.fill()
        
    }
}

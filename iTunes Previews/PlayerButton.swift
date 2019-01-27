//
//  PlayerButton.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import UIKit

@IBDesignable
class PlayerButton: UIButton {

    @IBInspectable var color: UIColor = UIColor.red
    @IBInspectable var isPauseButton: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var halfWidth: CGFloat {
        return bounds.width / 2
    }
    private var halfHeight: CGFloat {
        return bounds.height / 2
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect)
        let lineWidth: CGFloat = 2
        color.setFill()
        circlePath.fill()
        
        if isPauseButton {
            let distance: CGFloat = 10
            let halfLineHeight: CGFloat = 10
            
            let firstLineStartPoint = CGPoint(x: halfWidth - distance/2, y: halfHeight - halfLineHeight)
            let firstLineEndPoint = CGPoint(x: halfWidth - distance/2, y: halfHeight + halfLineHeight)
            let firstPath = UIBezierPath()
            firstPath.move(to: firstLineStartPoint)
            firstPath.addLine(to: firstLineEndPoint)
            firstPath.lineWidth = lineWidth
            
            let secondLineStartPoint = CGPoint(x: halfWidth + distance/2, y: halfHeight - halfLineHeight)
            let secondLineEndPoint = CGPoint(x: halfWidth + distance/2, y: halfHeight + halfLineHeight)
            let secondPath = UIBezierPath()
            secondPath.move(to: secondLineStartPoint)
            secondPath.addLine(to: secondLineEndPoint)
            secondPath.lineWidth = lineWidth
            
            UIColor.white.setStroke()
            firstPath.stroke()
            secondPath.stroke()
        } else {
            let horizontalOffset: CGFloat = 7
            let startPoint = CGPoint(x: halfWidth/2 + horizontalOffset, y: halfHeight/2)
            let middlePoint = CGPoint(x: halfWidth/2 + halfWidth - horizontalOffset/3, y: halfHeight)
            let endPoint = CGPoint(x: halfWidth/2 + horizontalOffset, y: halfHeight/2 + halfHeight)
            let trianglePath = UIBezierPath()
            trianglePath.move(to: startPoint)
            trianglePath.addLine(to: middlePoint)
            trianglePath.addLine(to: endPoint)
            trianglePath.addLine(to: startPoint)
            trianglePath.lineWidth = lineWidth
            UIColor.white.setStroke()
            trianglePath.stroke()
        }
    }

}

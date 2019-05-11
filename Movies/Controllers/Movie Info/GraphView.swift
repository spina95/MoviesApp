//
//  GraphView.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 05/09/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    private struct Constants {
        static let numberOfGlasses = 8
        static let lineWidth: CGFloat = 30
        static var halfOfLineWidth: CGFloat {
            return lineWidth / 2
        }
    }
    @IBInspectable var vote: Double = 0
    @IBInspectable var arcWidth: CGFloat = 5
    @IBInspectable var outlineColor: UIColor = UIColor.yellow
    @IBInspectable var counterColor: UIColor = UIColor.lightGray
    
    override func draw(_ rect: CGRect) {
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = min(bounds.width, bounds.height)
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = .pi * 2
        let path = UIBezierPath(arcCenter: center,
                                radius: radius/2 - arcWidth/2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        path.lineWidth = arcWidth
        counterColor.setStroke()
        path.stroke()
        
        let radius2: CGFloat = min(bounds.width, bounds.height)
        let startAngle2: CGFloat = 3/2 * .pi
        let endAngle2: CGFloat = CGFloat((vote * 2 * .pi/10) - .pi/2)
        let path2 = UIBezierPath(arcCenter: center,
                                radius: radius2/2 - arcWidth/2,
                                startAngle: startAngle2,
                                endAngle: endAngle2,
                                clockwise: false)
        path2.lineWidth = arcWidth
        path2.lineJoinStyle = .round
        outlineColor.setStroke()
        path2.stroke()
    }
    

}

//
//  GraphView.swift
//  Movies
//
//  Created by Andrea Spinazzola on 15/10/2018.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GraphUserView: UIView {
    
    private struct Constants {
        static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
        static let margin: CGFloat = 20
        static let topBorder: CGFloat = 20
        static let bottomBorder: CGFloat = 20
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
    }
    
    //Weekly sample data
    var graphPoints = [4, 2, 6, 4, 5, 6, 3]
    
    @IBInspectable var startColor: UIColor = .red
    @IBInspectable var endColor: UIColor = .green
    
    override func draw(_ rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: .allCorners,
                                cornerRadii: Constants.cornerRadiusSize)
        path.addClip()
        
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            //Calculate the gap between points
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }
        // calculate the y point
        
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()!
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            return graphHeight + topBorder - y // Flip the graph
        }
        // draw the line graph
        let blueColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
        blueColor.setFill()
        blueColor.setStroke()
        
        // set up the points line
        let graphPath = UIBezierPath()
        graphPath.lineWidth = 2
        
        // go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
        
        // add points for each item in the graphPoints array
        // at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        graphPath.stroke()
        
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        //bottom line
        linePath.move(to: CGPoint(x: margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:  width, y: height - bottomBorder))
        let color = UIColor.lightGray
        color.setStroke()
        
        linePath.lineWidth = 1.5
        linePath.stroke()
        
        for i in 0...6 {
            //center line
            linePath.move(to: CGPoint(x: margin, y: graphHeight/6 * CGFloat(i) + bottomBorder ))
            linePath.addLine(to: CGPoint(x: width, y: graphHeight/6 * CGFloat(i) + bottomBorder))
        }
        linePath.lineWidth = 0.5
        linePath.stroke()
        //Draw vertical graph lines on the top of everything
        let linePath2 = UIBezierPath()
        
        //bottom line
        linePath2.move(to: CGPoint(x: margin, y:height - bottomBorder))
        linePath2.addLine(to: CGPoint(x: margin, y: 0))
        color.setStroke()
        
        linePath2.lineWidth = 1.5
        linePath2.stroke()

    }
}

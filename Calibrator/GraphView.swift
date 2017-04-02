//
//  GraphView.swift
//  Calibrator
//
//  Created by Alex Humphreys on 02.04.17.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {

    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor.red
    @IBInspectable var endColor: UIColor = UIColor.green
    @IBInspectable let topBorder:CGFloat = 60
    @IBInspectable let bottomBorder:CGFloat = 50
    @IBInspectable let margin:CGFloat = 20.0

    
    //Weekly sample data
    var graphPoints:[Int] = [4, 2, 6, 4, 5, 8, 3]
    var perfectCalibration:[(Int,Int)] = [(0,0), (100,100)]
    
    override func draw(_ rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        addClip(rect: rect)
        addBackground()
        
        let context = UIGraphicsGetCurrentContext()
        
        // TODO: work out how not to double this everyhwere
        let graphHeight = height - topBorder - bottomBorder

        // draw the line graph
        
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        //set up the points line
        var graphPath = UIBezierPath()
        //go to start of line
        graphPath.move(to: CGPoint(x:columnXPoint(rect: rect, column: 0),
                                   y:columnYPoint(rect: rect, graphPoint: graphPoints[0])))
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x:columnXPoint(rect: rect, column: i),
                                    y:columnYPoint(rect: rect, graphPoint: graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        //Create the clipping path for the graph gradient
        
        //1 - save the state of the context (commented out for now)
        context!.saveGState()
        
        //2 - make a copy of the path
        var clippingPath = graphPath.copy() as! UIBezierPath
        
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLine(to: CGPoint(
            x: columnXPoint(rect: rect, column: graphPoints.count - 1),
            y:height))
        clippingPath.addLine(to: CGPoint(
            x:columnXPoint(rect: rect, column: 0),
            y:height))
        clippingPath.close()
        
        //4 - add the clipping path to the context
        clippingPath.addClip()
        
        let highestYPoint = columnYPoint(rect: rect, graphPoint: graphPoints.max()!)
        let startPoint = CGPoint(x:margin, y: highestYPoint)
        let endPoint = CGPoint(x:margin, y:self.bounds.height)
        
        context!.drawLinearGradient(getGradient()!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: CGGradientDrawingOptions(rawValue: 0))
        context!.restoreGState()
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        

        drawPointCircles(rect: rect)
        drawHorizontalLines(rect: rect)
    
 }
    
    func addClip(rect: CGRect, width: Double = 8.0, height: Double = 8.0) {
        //set up background clipping area
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: width, height: height))
        path.addClip()
    }
    
    func addBackground() {
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        
        //6 - draw the gradient
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        context?.drawLinearGradient(getGradient()!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: [])
    }
    
    func getGradient() -> CGGradient? {
        let colors = [startColor.cgColor, endColor.cgColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        
        return gradient
    }
    
    func columnXPoint(rect: CGRect, column: Int) -> CGFloat {
        let width = rect.width

        //Calculate gap between points
        let spacer = (width - margin*2 - 4) /
                CGFloat((self.graphPoints.count - 1))
        var x:CGFloat = CGFloat(column) * spacer
        x += margin + 2
        return x
    }
    
    func columnYPoint(rect: CGRect, graphPoint: Int) -> CGFloat {
        // calculate the y point
        let height = rect.height
        
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()!
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
    }

    func drawHorizontalLines(rect: CGRect) {
        let height = rect.height
        let width = rect.width
        let graphHeight = height - topBorder - bottomBorder

        //Draw horizontal graph lines on the top of everything
        var linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x:margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin,
                                     y:topBorder))
        
        //center line
        linePath.move(to: CGPoint(x:margin,
                                  y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x:width - margin,
                                     y:graphHeight/2 + topBorder))
        
        //bottom line
        linePath.move(to: CGPoint(x:margin,
                                  y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:width - margin,
                                     y:height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
    
    func drawPointCircles(rect: CGRect) {
        //Draw the circles on top of graph stroke
        for i in 0..<graphPoints.count {
            var point = CGPoint(x:columnXPoint(rect: rect, column: i),
                                y:columnYPoint(rect: rect, graphPoint: graphPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalIn:
                CGRect(origin: point,
                       size: CGSize(width: 5.0, height: 5.0)))
            circle.fill()
        }
    }

}

//
//  Line.swift
//  Calibrator
//
//  Created by Alex Humphreys on 09.04.17.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit

struct Point {
    var x: Float = 0.0
    var y: Float = 0.0
}
struct Size {
    var width: Float = 0.0
    var height: Float = 0.0
    let verticalMargin: Float = 20.0
    let horizontalMargin: Float = 20.0

    var offsetWidth: Float {
        return width - horizontalMargin * 2
    }

    var offsetHeight: Float {
        return height - verticalMargin * 2
    }
}

struct Line {
    let points: [Point]
    let size: Size

    var screenPoints: [CGPoint] {
        return self.points.map({screenPointFor(point: $0)})
    }
    var maxX: Float {
        return points.map({$0.x}).max()!
    }
    var maxY: Float {
        return points.map({$0.y}).max()!
    }
    var path: UIBezierPath {
        let graphPath = UIBezierPath()
        graphPath.move(to: screenPoints.first!)

        for p in screenPoints.dropFirst() {
            graphPath.addLine(to: p)
        }
        return graphPath
    }

    init(points: [Point], size: Size) {
        self.points = points
        self.size = size
    }

    func screenPointFor(point: Point) -> CGPoint {
        let x = (size.offsetWidth * point.x / maxX) + size.horizontalMargin
        let y = (size.offsetHeight - size.offsetHeight * point.y / maxY) + size.verticalMargin

        return CGPoint(x: CGFloat(x) , y: CGFloat(y))
    }

    var pointMarkers: [UIBezierPath] {
        let markerSize: CGFloat = 5.0/2
        return screenPoints.map({ (p) -> UIBezierPath in
            let topLeft = CGPoint(x: p.x - markerSize, y: p.y - markerSize)
            let bounds = CGRect(origin: topLeft,
                                size: CGSize(width: 5.0, height: 5.0))
            return UIBezierPath(ovalIn: bounds)
        })
    }
}

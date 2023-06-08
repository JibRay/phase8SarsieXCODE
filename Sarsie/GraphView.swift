//
//  GraphView.swift
//  Sarsie
//
//  Created by Jib Ray on 4/26/23.
//

import SwiftUI

struct GraphView: View {
    let width: CGFloat?
    let height: CGFloat?
    var points = [CGPoint]()
    
    // width and height are display size in pixels.
    // The X and Y in points ranges from 0.0 to 1.0.
    init(width: CGFloat, height: CGFloat, points: [CGPoint]) {
        self.width = width
        self.height = height
        self.points = scalePoints(points)
    }

    var body: some View {
        Canvas { context, size in
            var path = Path()
            var y: CGFloat
            
            // Draw horizontal grid lines.
            for i in 0...2 {
                y = (CGFloat(i + 1) * height!) / 4
                path.move(to: CGPoint(x: 0.0, y: y))
                path.addLine(to: CGPoint(x: width!, y: y))
            }
            context.stroke(path, with: .color(.blue),
                           style: StrokeStyle(lineWidth: 2))
            
            // Draw the horizontal center line.
            path = Path()
            y = height! / 2
            path.move(to: CGPoint(x: 0.0, y: y))
            path.addLine(to: CGPoint(x: width!, y: y))
            context.stroke(path, with: .color(.red),
                           style: StrokeStyle(lineWidth: 5))

            // If there are data, plot the points.
            if !points.isEmpty {
                path = Path()
                // Build the path from the points array.
                for pathPoint in points {
                    if path.isEmpty {
                        path.move(to: pathPoint)
                    } else {
                        path.addLine(to: pathPoint)
                    }
                }
                context.stroke(
                    path, with: .color(.black),
                    style: StrokeStyle(lineWidth: 3))
            }
        }
        .frame(width: width, height: height)
        .background(Color(red: 0.8, green: 0.8, blue: 0.8))
    }
    
    // Scale and smooth the input points to fit the canvas. Range of x and y
    // in points must be 0.0 to < 1.0.
    func scalePoints(_ points: [CGPoint]) -> [CGPoint] {
        let smoothedPoints = smooth(points)
        var scaledPoints = [CGPoint]()
        
        if !smoothedPoints.isEmpty {
            // Scale factors:
            let kx = width!
            let ky = height!
            
            for point in smoothedPoints {
                let x = kx * point.x
                let y = height! - (ky * point.y)
                scaledPoints.append(CGPoint(x: x, y: y))
            }
        }
        
        return scaledPoints
    }
    
    // Low-pass filter the data points.
    func smooth(_ points: [CGPoint]) -> [CGPoint] {
        let windowSize = 40 // Must be an even number.
        var smoothedPoints = [CGPoint]()
        var previousPoint: CGPoint?
        
            if !points.isEmpty {
                // Increase the number of points by a factor of 4 x windowSize.
                for point in points {
                    if (previousPoint != nil) {                        
                        // Use linear interpolation to fill in between original
                        // points.
                        let dx = point.x - previousPoint!.x
                        let dy = point.y - previousPoint!.y
                        for step in stride(from: 0, to: 1.0, by: 0.25 / Double(windowSize)) {
                            let xStep = previousPoint!.x + (step * dx)
                            let yStep = previousPoint!.y + (step * dy)
                            smoothedPoints.append(CGPoint(x: xStep, y: yStep))
                        }
                    }
                    previousPoint = point
                }
                
                // Apply low-pass filter.
                let halfWindow = windowSize / 2
                for toIndex in stride(from: 0, to: smoothedPoints.count, by: 1) {
                    let start = toIndex > halfWindow ? toIndex - halfWindow : 0
                    let end = toIndex < smoothedPoints.count - halfWindow ?
                        toIndex + halfWindow : smoothedPoints.count - 1
                    var sum = 0.0
                    for fromIndex in stride(from: start, to: end, by: 1) {
                        sum += smoothedPoints[fromIndex].y
                    }
                    smoothedPoints[toIndex].y = sum / Double(end - start)
                }
            }
        
        return smoothedPoints
    }
}

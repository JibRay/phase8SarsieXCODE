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
    
    // Size of points must be <= 100. The X and Y in points ranges
    // from 0.0 to 1.0.
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
            path = Path()
            y = height! / 2
            path.move(to: CGPoint(x: 0.0, y: y))
            path.addLine(to: CGPoint(x: width!, y: y))
            context.stroke(path, with: .color(.red),
                           style: StrokeStyle(lineWidth: 5))

            // If there are data, plot the points.
            if !points.isEmpty {
                path = Path()
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
    
    // Scale the input points to fit the canvas. Range of x and y
    // in points must be 0.0 to 1.0.
    func scalePoints(_ points: [CGPoint]) -> [CGPoint] {
        var scaledPoints = [CGPoint]()
        
        if !points.isEmpty {
            // Scale factors:
            let kx = width!
            let ky = height!
            
            for point in points {
                let x = kx * point.x
                let y = height! - (ky * point.y)
                scaledPoints.append(CGPoint(x: x, y: y))
            }
        }
        
        return scaledPoints
    }
}

/*
 struct ChartValue {
 let value: Double
 let underlyingValue: Double
 }
 
 class ChartModel {
 let values: [ChartValue]
 
 init (values: [ChartValue]) {
 self.values = values
 }
 }
 
 extension ChartModel {
 static func from(rawValues: [Double]) -> ChartModel? {
 // If we have more than one value get the largest. Else fail.
 guard rawValues.count > 1, let largestValue = rawValues.sorted(by: >).first else {
 return nil
 }
 let chartValues = rawValues.map { rawValue -> ChartValue in
 let value = rawValue / largestValue
 return ChartValue(value: max(0, value), underlyingValue: rawValue)
 
 }
 return ChartModel(values: chartValues)
 }
 }
 
 protocol ChartView: View {
 var insets: CGFloat { get }
 var stokeWidth: CGFloat { get }
 var color: Color { get }
 var model: ChartModel { get }
 }
 
 extension ChartView {
 func makeChartPoints(from dataPoints: [ChartValue], size: CGSize) -> [ChartValue]  {
 var currentX: CGFloat = insets
 var size = size
 size.height = size.height - insets * 2
 size.width = size.width - insets * 2
 currentX += xValuesPerPoint(size: size)
 return ChartPoint()
 }
 }
 */

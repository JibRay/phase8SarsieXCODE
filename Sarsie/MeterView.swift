//
//  MeterView.swift
//  Sarsie
//
//  Created by Jib Ray on 4/25/23.
//

import SwiftUI

struct Needle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Draw the needle.
        path.move(to: CGPoint(x: rect.midX + 5, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX - 5, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

// UI graphics have zero at upper left corner.
struct MeterView: View {
    let width: CGFloat?
    let height: CGFloat?
    let value: Double?
    
    let minAngle: Double = 0.2 // Radians
    let maxAngle: Double = 0.8
    let angleStep: Double?
    var pointerCenter = CGPoint(x: 0, y: 0)
    var pointerRadius: Double?

    // width and height are over all size of the meter. value is the
    // value displayed by the meter, 0.0 to 1.0.
    init(width: CGFloat, height: CGFloat, value: Double) {
        self.width = width
        self.height = height
        
        // Convert value to angle in radians. Note that from here on
        // zero is the needle at half scale, pointing straight up.
        self.value = (value - 0.5) * 2.0
        angleStep = (maxAngle - minAngle) / 5.0001
        self.pointerCenter.x = 0.5 * width
        self.pointerCenter.y = 0.8 * height
        self.pointerRadius = 0.65 * height
    }
    
    var body: some View {
        // Needle is a tapered quadralateral with a circle at its pivot.
        let origin = CGPoint(x: pointerCenter.x - 15, y: pointerCenter.y - 15)
        let pointerPivotBox = CGRect(origin: origin, size: CGSize(width: 30, height: 30))
        let pointerPivot = Circle().path(in: pointerPivotBox)
        
        // Needle is red left of the mid-point and green right of the midpoint.
        let pointerColor = value! > 0.0 ? Color.red : Color.green
        
        // Create the needle graphic.
        let needleSize = CGSize(width: 20, height: 1.2 * pointerRadius!)
        let needleBox = CGRect(origin: CGPoint(x: pointerCenter.x - 10, y: 30), size: needleSize)
        let needle = Needle().path(in: needleBox)
        
        // Rotate needle so its angle represents the value parameter.
        let rotatedNeedle = rotateNeedle(needle, by: value!, radius: pointerRadius!)
        
        // Meter index marks are dots.
        let meterDots = meterDots(center: pointerCenter, radius: pointerRadius! + 12.0)
        
        
        Canvas {
            // Draw the circle at the pointer pivot, the meter index marks
            // (dots) and finally the needle.
            context, size in
            context.fill(pointerPivot, with: .color(pointerColor))
            for meterDot in meterDots {
                context.fill(meterDot, with: .color(.white))
            }
            context.fill(rotatedNeedle, with: .color(pointerColor))
        }
        .frame(width: width, height: height)
        //.border(Color.blue) // For testing layout.
    }
    
    // Move Y zero from the bottom of a rectangle to the top.
    private func toTop(_ y: CGFloat) -> CGFloat {
        return height! - y
    }
    
    // Rotate needle to a new angle. Then translate it so needle point
    // is on the correct arc.
    private func rotateNeedle(_ path: Path, by angle: Double, radius: Double) -> Path {
        
        // Calculate translation needed after rotating the needle. Rotation
        // anchor is the upper left corner of this view.
        let radiusToPivot = sqrt(pow(pointerCenter.x, 2.0) + pow(pointerCenter.y, 2.0))
        let angleToNewPivot = atan(pointerCenter.y / pointerCenter.x) + angle
        let newPivotX = radiusToPivot * cos(angleToNewPivot)
        let newPivotY = radiusToPivot * sin(angleToNewPivot)
        let dX = pointerCenter.x - newPivotX
        let dY = pointerCenter.y - newPivotY
        
        let transform = CGAffineTransform(rotationAngle: angle)
        return path.applying(transform).offsetBy(dx: dX, dy: dY)
    }
    
    // Create the meter index marks (dots).
    private func meterDots(center: CGPoint, radius: Double) -> [Path] {
        var dots = [Path]()
        
        for k in stride(from: minAngle, through: maxAngle, by: angleStep!) {
            let x = center.x + (radius * cos(k * Double.pi)) - 7.5
            let y = center.y - (radius * sin(k * Double.pi))
            dots.append(Circle().path(in: CGRect(x: x, y: y, width: 15, height: 15)))
        }
        return dots
    }
}

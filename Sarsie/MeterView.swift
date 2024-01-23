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
        
        // Draw the needle inside rect.
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
    let screenRect = UIScreen.main.bounds
    let width: CGFloat?
    let height: CGFloat?
    
    let minAngle: Double = 0.2 // Radians
    let maxAngle: Double = 0.8
    let angleStep: Double?
    var screenWidth: Double
    var screenHeight: Double
    var pointerCenter = CGPoint(x: 0, y: 0)
    var pointerRadius: Double?
    
    var valueAngle = 0.0
    var thresholdAngle = 0.0

    // width and height are over all size of the meter. value is the
    // value displayed by the meter, 0.0 to <1.0.
    init(width: CGFloat, height: CGFloat, value: Double, positiveThreshold: Double) {
        self.screenWidth = screenRect.size.width
        self.screenHeight = screenRect.size.height
        self.width = width
        self.height = height
        
        // Convert value and threshold (0.0 to <1.0) to angles in radians.
        // Note that from here on zero is the needle at half scale, pointing
        // straight up.
        self.valueAngle = (2.0 * value) - 1.0
        self.thresholdAngle = (2.0 * positiveThreshold) - 1.0
        angleStep = (maxAngle - minAngle) / 5.0001
        self.pointerCenter.x = 0.5 * width
        self.pointerCenter.y = 0.8 * height
        self.pointerRadius = 0.65 * height
    }
    
    // In the following there are cases where it makes more sense to scale a
    // horizontal by the screenHeight. Sizing a square box for example.
    var body: some View {
        // Needle is a tapered quadralateral with a circle at its pivot.
        let origin = CGPoint(x: pointerCenter.x - (0.0176 * screenHeight),
                             y: pointerCenter.y - (0.0176 * screenHeight))
        let boxSize = CGSize(width: 0.0352 * screenHeight, height: 0.0352 * screenHeight)
        let pointerPivotBox = CGRect(origin: origin, size: boxSize)
        let pointerPivot = Circle().path(in: pointerPivotBox)
        
        // Needle is green left of thresholdAngle and red right of it.
        let pointerColor = valueAngle >= thresholdAngle ? Color.red : Color.green
        
        // Create the needle graphic.
        let needleSize = CGSize(width: 0.0235 * screenHeight,
                                height: 1.2 * pointerRadius!)
        let needleBox = CGRect(
            origin: CGPoint(x: pointerCenter.x - 0.0117 * screenHeight,
                            y: 0.0352 * screenHeight), size: needleSize)
        let needle = Needle().path(in: needleBox)
        
        // Rotate needle so its angle represents the value parameter.
        let rotatedNeedle = rotateNeedle(needle, by: valueAngle, radius: pointerRadius!)
        
        // Meter index marks are dots.
        let meterDots = meterDots(center: pointerCenter,
                                  radius: pointerRadius! + 0.0141 * screenHeight)
        
        
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
    // is on the correct arc. Range of angle argument is -1.0 to +1.0.
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
        let dotSize = 0.0176 * screenHeight
        
        for k in stride(from: minAngle, through: maxAngle, by: angleStep!) {
            let x = center.x + (radius * cos(k * Double.pi)) - (dotSize / 2.0)
            let y = center.y - (radius * sin(k * Double.pi))
            dots.append(Circle().path(in: CGRect(x: x, y: y, width: dotSize, height: dotSize)))
        }
        return dots
    }
}

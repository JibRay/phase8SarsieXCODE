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
        
        path.move(to: CGPoint(x: rect.midX + 5, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX - 5, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct MeterView: View {
    let _width: CGFloat?
    let _height: CGFloat?
    let _value: Double?
    
    let minAngle: Double = 0.2 // Radians
    let maxAngle: Double = 0.8
    let angleStep: Double?
    var pointerCenter = CGPoint(x: 0, y: 0)
    let offsets: [(x: Double, y: Double)] =
    [
        (-179.0, 51.0),
        (-140.0, 53.0),
        (-102.0, 47.0),
        (-66.0, 37.0),
        (-31.0, 22.0),
        (0.0, 0.0),
        (28.0, -27.0),
        (52.0, -57.0),
        (70.0, -90.0),
        (82.0, -127.0),
        (89.0, -164)
    ]

    init(width: CGFloat, height: CGFloat, value: Double) {
        _width = width
        _height = height
        _value = (value - 0.5) * 1.6 // Convert value to radians.
        angleStep = (maxAngle - minAngle) / 5.0001
        pointerCenter.x = 0.5 * _width!
        pointerCenter.y = 0.3 * _height!
    }
    
    var body: some View {
        let origin = CGPoint(x: pointerCenter.x - 15, y: toTop(pointerCenter.y) + 15)
        let originSize = CGSize(width: 30, height: 30)
        let pointerPivotBox = CGRect(origin: origin, size: originSize)
        
        let pointerPivot = Circle().path(in: pointerPivotBox)
        let pointerRadius = 0.65 * _height!
        let pointerColor = _value! > 0.0 ? Color.red : Color.green
        let needleSize = CGSize(width: 20, height: 1.2 * pointerRadius)
        let needleBox = CGRect(origin: CGPoint(x: pointerCenter.x - 10, y: 30), size: needleSize)

        let needle = Needle().path(in: needleBox)
        let rotatedNeedle = rotatePath(needle, by: _value!)
        
        let meterDots = meterDots(center: pointerCenter, radius: pointerRadius)
        
        
        Canvas {
            context, size in
            context.fill(pointerPivot, with: .color(pointerColor))
            for meterDot in meterDots {
                context.fill(meterDot, with: .color(.white))
            }
            context.fill(rotatedNeedle, with: .color(pointerColor))
        }
        .frame(width: _width, height: _height)
        //.border(Color.blue)
    }
    
    // Move Y zero from the bottom of a rectangle to the top.
    private func toTop(_ y: CGFloat) -> CGFloat {
        return _height! - y
    }
    
    // Range of angle is -0.8 to +0.8.
    // FIXME: Add interpolation.
    func offset(_ angle: Double) -> (x: Double, y: Double) {
        var index: Int = Int(0.5 + ((angle + 0.8) * 6.25))
        index = index < 0 ? 0 : index
        index = index > 10 ? 10 : index
        
        return offsets[index]
    }

    private func rotatePath(_ path: Path, by angle: Double) -> Path {
        let offset = offset(angle)
        let transform = CGAffineTransform(rotationAngle: angle)
            .translatedBy(x: offset.x, y: offset.y)
        return path.applying(transform)
    }
    
    /*
    private func rotatePath(_ path: Path, by angle: Double) -> Path {
        let px = pointerCenter.x
        let py = toTop(pointerCenter.y)
        
        // Compute radius to pointer center (pivot).
        let r = sqrt((px * px) + (py * py))
        
        // Compute angle to pointer center.
        let a0 = atan(py / px)
        
        // Compute angle to rotated pointer center.
        let a1 = a0 + angle
        
        // Compute position of rotated pointer center.
        let x = r * cos(a1)
        let y = r * sin(a1)
        
        // Compute translation to move pointer back to pivot.
        let dx = x - px
        let dy = y - py
        //let dx = px - x
        //let dy = py - y

        let transform = CGAffineTransform(rotationAngle: angle)
            //.translatedBy(x: dx, y: dy)
            .translatedBy(x: -180, y: 53)
        return path.applying(transform)
    }
     */
    
    private func meterDots(center: CGPoint, radius: Double) -> [Path] {
        var dots = [Path]()
        
        for k in stride(from: minAngle, through: maxAngle, by: angleStep!) {
            let x = center.x + (radius * cos(k * Double.pi)) - 7.5
            let y = toTop(center.y + (radius * sin(k * Double.pi)))
            dots.append(Circle().path(in: CGRect(x: x, y: y, width: 15, height: 15)))
        }
        return dots
    }
}

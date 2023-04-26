//
//  MeterView.swift
//  Sarsie
//
//  Created by Jib Ray on 4/25/23.
//

import SwiftUI

struct MeterView: View {
    let _width: CGFloat?
    let _height: CGFloat?
    let _value: Double?
    
    let minAngle: Double = 0.2
    let maxAngle: Double = 0.8
    let angleStep: Double?
    
    init(width: CGFloat, height: CGFloat, value: Double) {
        _width = width
        _height = height
        _value = value  // 0.0 to 1.0
        angleStep = (maxAngle - minAngle) / 5.0001
    }
    
    var body: some View {
        let pointerCenter = CGPoint(x: 0.5 * _width!, y: 0.3 * _height!)
        
        let origin = CGPoint(x: pointerCenter.x - 15, y: toTop(pointerCenter.y) + 15)
        let originSize = CGSize(width: 30, height: 30)
        let pointerPivotBox = CGRect(origin: origin, size: originSize)
        
        let pointerPivot = Circle().path(in: pointerPivotBox)
        let pointerRadius = 0.65 * _height!
        let pointerColor = _value! > 0.5 ? Color.red : Color.green
        //let meterDot = Circle().path(in: CGRect(x: 150, y: 100, width: 15, height: 15))
        
        let meterDots = meterDots(center: pointerCenter, radius: pointerRadius)
        
        Canvas {
            context, size in
            context.fill(pointerPivot, with: .color(pointerColor))
            for meterDot in meterDots {
                context.fill(meterDot, with: .color(.white))
            }
        }
        .frame(width: _width, height: _height)
        .border(Color.blue)
    }
    
    // Move Y zero from the bottom of a rectangle to the top.
    private func toTop(_ y: CGFloat) -> CGFloat {
        return _height! - y
    }
    
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

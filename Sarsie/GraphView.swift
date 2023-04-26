//
//  GraphView.swift
//  Sarsie
//
//  Created by Jib Ray on 4/26/23.
//

import SwiftUI

struct Plot: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.stroke(.red, lineWidth: 4)
        
        return path
    }
}

struct GraphView: View {
    let _width: CGFloat?
    let _height: CGFloat?
    
    var plotBox = CGRect()
    
    init(width: CGFloat, height: CGFloat) {
        _width = width
        _height = height
        plotBox.origin = CGPoint(x: 0, y: 0)
        plotBox.size = CGSize(width: _width!, height: _height!)
    }

    var body: some View {
        /*
        Path() { path in
            path.move(to: CGPoint(x: 0, y: _height! / 2))
            path.addLine(to: CGPoint(x: _width!, y: _height! / 2))
        }
        .stroke(Color.red, lineWidth: 4)
         */
        let plot = Plot().path(in: plotBox)
        
        Canvas {
            context, size in
            context.fill(plot, with: .color(.red))
        }
        .frame(width: _width, height: _height)
        .background(Color.white)
        .border(Color.blue)
    }
}

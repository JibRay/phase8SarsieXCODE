//
//  VirusTest.swift
//  Sarsie
//
//  Created by Jib Ray on 5/6/23.
//

import SwiftUI
class DemoData {
    let scale: Double?
    let offset: Double?
    var index: Int
    
    // Original capture data from HL 2 DATA SHEET DAY 8 HERO
    let  values: [Double] = [
        1002312944, 1002492623, 1002281541, 1002232514, 1002439777,
        1002232209, 1002908290, 1002707138, 1002528358, 1002468216,
        1002561342, 1002316280, 1002467965, 1002506489, 1002427972,
        1002621989, 1002421999, 1002371144, 1002453970, 1002604630,
        1002341604, 1002322062, 1002306184, 1002585855, 1002408872,
        1002516742, 1002627998, 1002251587, 1002556788, 1002614089,
        1002508276, 1002414499, 1002220331, 1002418568, 1002202776,
        1002209872, 1002312944, 1002492623, 1002281541, 1002232514,
        1002439777, 1002232209, 1002908290, 1002707138, 1002528358,
        1002468216, 1002561342, 1002316280, 1002467965, 1002506489,
        1002427972, 1002621989, 1002421999, 1002371144, 1002453970,
        1002604630, 1002341604, 1002322062, 1002306184, 1002585855,
        1002408872, 1002516742, 1002627998, 1002251587, 1002556788,
        1002614089, 1002508276, 1002414499, 1002220331, 1002418568,
        1002202776, 1002209872
    ]
    
    var size: Int {
        get {
            return values.count
        }
    }
    
    init() {
        self.index = 0
        
        var min = 1e14
        var max = 0.0
        for value in values {
            min = value < min ? value : min
            max = value > max ? value : max
        }
        
        scale = 0.9 / (max - min)
        offset = (scale! * min) - 0.05
    }
    
    func getNextValue() -> (value: CGPoint, index: Int) {
        let returnedIndex = index
        let x = Double(index) / Double(values.count)
        let y = (values[self.index] * scale!) - offset!
        self.index += 1
        self.index = self.index >= values.count ? 0 : self.index
        return (CGPoint(x: x, y: y), returnedIndex)
    }
}

class VirusTest {
    var demoData: DemoData
    
    init() {
        self.demoData = DemoData()
    }
    
    func test(pixelBuffer: CVImageBuffer) -> (value: CGPoint, index: Int) {
        /*
         let width = CVPixelBufferGetWidth(pixelBuffer)
         let height = CVPixelBufferGetHeight(pixelBuffer)
         let planeCount = CVPixelBufferGetPlaneCount(pixelBuffer)
         let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
         let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
         */
        
        return demoData.getNextValue()
    }
}

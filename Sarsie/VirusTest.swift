//
//  VirusTest.swift
//  Sarsie
//
//  Created by Jib Ray on 5/6/23.
//

import SwiftUI

struct TestResult {
    var count: Int
    var sum: Int
    var value: Double
}

struct Pixel {
    var blue: UInt8
    var green: UInt8
    var red: UInt8
    var alpha: UInt8
}

class VirusTest {
    // Run a virus test by analyzing the image passed in imageData.
    func test(imageData: Data) -> TestResult {
        var pixels = [Pixel]()
        var sum = 0
        
        // Extract pixels from imageData.
        for index in stride(from: imageData.startIndex, to: (imageData.endIndex - 4), by: 4) {
            let pixel = Pixel(blue: imageData[index],
                              green: imageData[index+1],
                              red: imageData[index+2],
                              alpha: imageData[index+3])
            pixels.append(pixel)
            sum += Int(pixel.red) // Sum the red channel pixels.
        }
        let count = (imageData.endIndex - imageData.startIndex) / 4
        
        // value is the average red channel brightness.
        let value: Double = Double(sum) / Double(count)
        return TestResult(count: count, sum: sum, value: value)
    }
}

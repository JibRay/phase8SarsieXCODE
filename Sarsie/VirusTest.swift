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

class VirusTest {
    // Run a virus test by analyzing the image passed in imageData.
    func test(imageData: Data) -> TestResult {
        var sum = 0
        for index in stride(from: imageData.startIndex, to: imageData.endIndex, by: 1) {
            sum += Int(imageData[index])
        }
        let count = imageData.endIndex - imageData.startIndex
        let value: Double = Double(sum) / Double(count)
        return TestResult(count: count, sum: sum, value: value)
    }
}

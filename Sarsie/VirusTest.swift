//
//  VirusTest.swift
//  Sarsie
//
//  Created by Jib Ray on 5/6/23.
//

import SwiftUI
import CoreLocation

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
    @StateObject var locationManager = LocationManager()
    var version: Int
    var testingValue: Double = 0.0 // Only need this while testing.
    var sum = 0
    var hits = 0
    
    init(version: Int) {
        self.version = version
    }

    // Run a virus test by analyzing the image passed in imageData. This
    // function returns a TestResult object. TestResult.value has a
    // range of 0.0 - <1.0. Negative/positive decision is made by comparing
    // TestResult.value to DataModel.virusThreshold and is then displayed
    // as a red or green needle or a value above or below threshold line
    // in the graph.
    func test(imageData: Data) -> TestResult {
        var pixels = [Pixel]()
        var startIndex = imageData.startIndex + 32768
        
        sum = 0
        hits = 0
        for index in stride(from: startIndex, to: (imageData.endIndex - 4), by: 4) {
            if( imageData[index+2]  < 180 && imageData[index+2]  >  120)  {  // CLIP SPIKES
                sum += Int(imageData[index+2]) // Sum the old red channel pixels.
                hits += 1
            }
        }
        
         let count = hits
        // let count = (imageData.endIndex - startIndex) / 4
        //count = 12186087 always
         let value: Double = Double(sum) / (Double(hits) * 256.0)
        print("value = \(value)")
        //print("hits = \(hits)")

        writeTestResult(image: imageData, value: value)
       
        return TestResult(count: count, sum: sum, value: value)
    }
    
    // Write the captured image with prepended header to a file.
    func writeTestResult(image: Data, value: Double) {
        /* Test code:
        var testData = [UInt8]()
        for n in 0..<10000 {
            testData.append(UInt8(n & 255))
        }
        
        let data = Data(testData)
        do {
            let compressedData = try (data as NSData).compressed(using: .zlib)
        } catch {
            print(error.localizedDescription)
        }
         */
        
        // UIDevice.current.identifierForVendor!.uuidString
        
        // The output file is a 10240 byte header followed by the image.
        let formatter = DateFormatter() // Used to create date/time strings.
        var headerEntries = ""

        /* Example header entries. For now header contains only Sarsie
           version, value and end marker.
         
        headerEntries += "Sum: \(sum)\n"
        formatter.dateFormat = "y-M-d HH:mm:ss"
        headerEntries += "Date/time: " + formatter.string(from: Date.now) + "\n"
         */
        
        headerEntries += "Sarsie version: \(version)\n"
        headerEntries += "Value: \(value)\n"
        headerEntries += "End header\n"

        // Fill the remainder of the header with null characters.
        for _ in 0..<10240 - headerEntries.count {
            headerEntries += "\0"
        }
        
        let header = Data(headerEntries.utf8)
        let fileContent = header + image
        
        formatter.dateFormat = "y-M-d-HH-mm-ss"
        let filePath = formatter.string(from: Date.now) + ".sarsie"
        let url = URL.documentsDirectory.appending(path: filePath)
        print(url)
        do {
            try fileContent.write(to: url, options: [.atomic])
        } catch {
            print(error.localizedDescription)
        }
    }
}

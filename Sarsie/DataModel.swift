/*
See the License.txt file for this sample’s licensing information.
*/

import AVFoundation
import SwiftUI
import os.log
import CoreLocation
import CoreLocationUI

final class DataModel: ObservableObject {
    static let version = 60
    
    // When the repeatTests is set to true, pressing the button starts
    // repeating tests. Tests repeat at a regular interval set in the timer
    // object definition in ContentView.swift. Tests repeat until the button
    // is pressed a second time.
    let repeatTests = false
    
    let camera = Camera()
    let photoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)
    let virusTest = VirusTest(version: version)
    
    static let graphTop = 0.7
    static let graphBottom = 0.4
    
    // The next three constants must be set to control the threshold between
    // a negative or positive result and how the graph displays the result.
    
    // The positive virus threshold (range: 0.0 - <1.0). This ultimately
    // controls the color of the needle and the offset of the data with
    // respect to the red grid line in the graph.
    let virusThreshold = (graphTop + graphBottom) / 2.0
    
    // The maximum mumber of test results shown on the graph.
    let resultsPerGraph = 8
    
    // The graph vertical scale factor. This scales the value to a range
    // of 0.0 to 1.0.
    let graphScale = 1.0 / (graphTop - graphBottom)
    
    var testResult = TestResult(count: 0, sum: 0, value: 0)
    var scaledTestResult = 0.0
    var graphPoints = [CGPoint]()
    
    @Published var viewfinderImage: Image?
    @Published var thumbnailImage: Image?
    
    var isPhotosLoaded = false
    
    private var graphYoffset = 0.0
    private var resultCount = 0

    init() {
        graphYoffset = 0.5 - (graphScale * virusThreshold)
        Task {
            await handleCameraPreviews()
        }
        
        Task {
            await handleCameraPhotos()
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0.image }

        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
    
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            Task { @MainActor in
                thumbnailImage = photoData.thumbnailImage
            }
            // I don't think we need to do this:
            //savePhoto(imageData: photoData.imageData)
            
            // Pass the image to virusTest for analysis.
            testResult = await virusTest.test(imageData: photoData.imageData)
            updateTestResults(testResult: testResult)
        }
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    
    func savePhoto(imageData: Data) {
        Task {
            do {
                try await photoCollection.addImage(imageData)
                logger.debug("Added image data to photo collection.")
            } catch let error {
                logger.error("Failed to add image to photo collection: \(error.localizedDescription)")
            }
        }
    }
    
    func loadPhotos() async {
        guard !isPhotosLoaded else { return }
        
        let authorized = await PhotoLibrary.checkAuthorization()
        guard authorized else {
            logger.error("Photo library access was not authorized.")
            return
        }
        
        Task {
            do {
                try await self.photoCollection.load()
                await self.loadThumbnail()
            } catch let error {
                logger.error("Failed to load photo collection: \(error.localizedDescription)")
            }
            self.isPhotosLoaded = true
        }
    }
    
    func loadThumbnail() async {
        guard let asset = photoCollection.photoAssets.first  else { return }
        await photoCollection.cache.requestImage(for: asset, targetSize: CGSize(width: 256, height: 256))  { result in
            if let result = result {
                Task { @MainActor in
                    self.thumbnailImage = result.image
                }
            }
        }
    }
    
    func updateTestResults(testResult: TestResult) {
        resultCount += 1
        
        // If the graph is empty insert a starting point.
        if (graphPoints.count == 0) {
            graphPoints.append(CGPoint(x: 0.0, y: 0.5))
        }
        // If near the X limit, scroll graph to the left.
        if (graphPoints.count > resultsPerGraph - 1) {
            for i in stride(from: graphPoints.count - 1, to: 0, by: -1) {
                graphPoints[i].x = graphPoints[i-1].x
            }
            graphPoints.removeFirst()
        }
        
        scaledTestResult = (testResult.value * graphScale) + graphYoffset
        let x = Double(graphPoints.count) / Double(resultsPerGraph)
        graphPoints.append(CGPoint(x: x, y: scaledTestResult))
    }
}

fileprivate struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined

    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
    }

    public func requestAuthorisation(always: Bool = false) {
        if always {
            self.manager.requestAlwaysAuthorization()
        } else {
            self.manager.requestWhenInUseAuthorization()
        }
    }

    func requestLocation() {
        manager.requestLocation()
    }
}

extension LocationManager {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorisationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.sarsie", category: "DataModel")

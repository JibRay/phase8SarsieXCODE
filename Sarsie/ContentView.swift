//
//  ContentView.swift
//  Sarsie
//
//  Created by Jib Ray on 3/23/23.
//

import SwiftUI

struct ContentView: View {
    @State var testValue = 0.0
    @StateObject var model = DataModel()
    @State var graphPoints = [CGPoint]()
    let screenRect = UIScreen.main.bounds

    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea(.all)
            VStack {
                let screenWidth = screenRect.size.width
                let screenHeight = screenRect.size.height
                Button {
                    model.camera.takePhoto()
                }
                label: {
                    Label {
                        Text("")
                    } icon: {
                        ZStack {
                            Circle()
                                .strokeBorder(.white, lineWidth: 3)
                                .frame(width: 0.194 * screenHeight, height: 0.194 * screenHeight)
                            Circle()
                                .fill(.yellow)
                                .frame(width: 0.176 * screenHeight, height: 0.176 * screenHeight)
                        }
                    }
                }
                HStack {
                    Text(" SARSIE")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("\u{2122}")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                }
                MeterView(width: 0.763 * screenWidth,
                          height: 0.235 * screenHeight,
                          value: model.testResult.value,
                          positiveThreshold: model.virusThreshold)
                
                // Display test value (count & sum returned from VirusTest.test()).
                Text("\(model.testResult.count) \(model.testResult.sum) \(model.testResult.value)")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                GraphView(width: 0.992 * screenWidth,
                          height: 0.235 * screenHeight, points: model.graphPoints)
                TimeAndLocationView()
                Spacer()
                // For release set size to 4 x 3. For testing
                // make it larger, like 40 x 30. The camera
                // start task is required, so need to keep this.
                ViewfinderView(image:  $model.viewfinderImage)
                    .frame(width: 40, height: 30)
                    .task {
                        await model.camera.start()
                        await model.loadThumbnail()
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

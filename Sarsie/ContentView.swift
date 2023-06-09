//
//  ContentView.swift
//  Sarsie
//
//  Created by Jib Ray on 3/23/23.
//

import SwiftUI

struct ContentView: View {
    @State var testValue = 0.0
    @StateObject private var model = DataModel()
    @State var graphPoints = [CGPoint]()

    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea(.all)
            VStack {
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
                                .frame(width: 165, height: 165)
                            Circle()
                                .fill(.yellow)
                                .frame(width: 150, height: 150)
                        }
                    }
                }
                HStack {
                    Text(" SARSIE")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("\u{00A9}")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                }
                MeterView(width: 300, height: 200, value: model.scaledTestResult)
                
                // Display test value (count & sum returned from VirusTest.test()).
                Text("\(model.testResult.count) \(model.testResult.sum) \(model.testResult.value)")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                GraphView(width: 390, height: 200, points: model.graphPoints)
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

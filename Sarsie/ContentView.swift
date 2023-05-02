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

    @State var outputLog: String = "Sarsie version 3\n"
    
    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea(.all)
            VStack {
                Button {
                    outputLog += "Start test\n"
                    model.camera.takePhoto()
                    testValue += 0.1
                    testValue = testValue > 1.0 ? 0.0 : testValue
                    graphPoints = [CGPoint]()
                    for i in  0..<100 {
                        let x = Double(i) / 100.0
                        let y = 0.5 + 0.5 * cos(Double.pi + ((Double(i) * 2.0 * Double.pi) / 100.0))
                        graphPoints.append(CGPoint(x: x, y: y))
                    }
                } label: {
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
                Text("SARSIE")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                MeterView(width: 300, height: 225, value: testValue)
                GraphView(width: 390, height: 220, points: graphPoints)
                TimeAndLocationView()
                /*
                Text("GPS: 42.040919,-74.117995")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                Text("3/30/2023 3:30:24 PM EDT")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                 */
                Spacer()
                // Log TextField & ViewfinderView are used just for
                // testing.
                /*
                TextField("log", text: $outputLog, axis: .vertical)
                    //.foregroundColor(.blue)
                    .background(.gray)
                    .frame(width: 300, height: 140)
                    .padding()
                Spacer()
                ViewfinderView(image:  $model.viewfinderImage)
                    .frame(width: 300, height: 200)
                    .task {
                        await model.camera.start()
                    }
                 */
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

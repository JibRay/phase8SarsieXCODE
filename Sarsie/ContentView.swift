//
//  ContentView.swift
//  Sarsie
//
//  Created by Jib Ray on 3/23/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = DataModel()

    @State var outputLog: String = "Sarsie version 3\n"
    
    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea(.all)
            VStack {
                Button {
                    outputLog += "Start test\n"
                    model.camera.takePhoto()
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
                MeterView(width: 300, height: 225, value: 0.51)
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

//
//  ContentView.swift
//  Sarsie
//
//  Created by Jib Ray on 3/23/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = DataModel()

    @State var outputLog: String =
    "Sarsie version 2\n"
    + "Output log\n"
    + "To use this for debugg, write\n"
    + "to State var outputLog.\n"
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        // This button initiates the test.
                        Button ("", action: {})
                            .frame (width: 150, height: 150)
                            .background(.yellow)
                            .clipShape(Circle())
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 165, height: 165)
                        
                    }
                    .padding()
                }
                Text("SARSIE")
                    .bold()
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                // Comment this TextField for release version.
                TextField("log", text: $outputLog, axis: .vertical)
                    //.foregroundColor(.blue)
                    .background(.gray)
                    .frame(width: 300, height: 140)
                    .padding()
                //Image("ArmoredCarp01")
                //NavigationStack {
                //.resizable()
                //.scaledToFit()
                //}
                Spacer()
                // Comment this ViewfinderView for release version.
                ViewfinderView(image:  $model.viewfinderImage)
                    .frame(width: 300, height: 200)
                    .task {
                        await model.camera.start()
                    }
            }
        }
        .buttonStyle(.plain)
        //.task {
        //    await model.camera.start()
        //}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

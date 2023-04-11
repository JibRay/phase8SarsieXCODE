//
//  ContentView.swift
//  Sarsie
//
//  Created by Jib Ray on 3/23/23.
//

import SwiftUI

struct ContentView: View {
    @State var outputLog: String =
    " 1 Sarsie version 1\n"
    + " 2 Output log\n"
    + " 3 A place to\n"
    + " 4 write debug info.\n"
    + " 5 This will be removed\n"
    + " 6 in the published\n"
    + " 7 version. This can\n"
    + " 8 display intermediate\n"
    + " 9 results and progress\n"
    + "10 information.\n"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
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
                    // Comment this TextField and Image for release version.
                    TextField("log", text: $outputLog, axis: .vertical)
                        //.foregroundColor(.blue)
                        .background(.gray)
                        .frame(width: 300, height: 150)
                Image("ArmoredCarp01")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
                    // End comment section.
                    Spacer()
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

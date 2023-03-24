//
//  ContentView.swift
//  Sarsie
//
//  Created by Jib Ray on 3/23/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Color.black.edgesIgnoringSafeArea(.all)
            Color.black.ignoresSafeArea(.all)
            VStack {
                Spacer()
                    .frame(maxHeight: 50)
                Rectangle()
                    .fill(Color(red: 1, green: 0, blue: 0))
                    .frame(width: 50, height: 50)
                Spacer()
                Button("Start", action: {})
                    .padding()
                    .font(.system(size: 60))
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .clipShape(Capsule())
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

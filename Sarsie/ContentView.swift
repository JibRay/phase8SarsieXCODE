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
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                    .frame(maxHeight: 50)
                Rectangle()
                    .fill(Color.pink)
                    .frame(width: 50, height: 50)
                Spacer()
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

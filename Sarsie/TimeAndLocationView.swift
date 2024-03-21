//
//  TimeAndLocationView.swift
//  Sarsie
//
//  Created by Jib Ray on 5/1/23.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

struct TimeAndLocationView: View {
    @State var date = Date()
    //@StateObject var locationManager = LocationManager()
    //@State var locationManager = LocationManager()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        //locationManager.requestAuthorisation()
    }
    
    var body: some View {
        VStack {
            /*
            if let location = locationManager.location {
                Text("Location: \(location.latitude), \(location.longitude)")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
             */
            Text(date, formatter: dateFormatter)
                //.onReceive(timer) { _ in
                //    date = .now
                //}
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
        .onReceive(timer) { _ in
            date = .now
            //locationManager.requestLocation()
        }
    }
}


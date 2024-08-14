//
//  ContentView.swift
//  Sarsie
//
//  Created by Jib Ray on 3/23/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var testValue = 0.0
    @StateObject var model = DataModel()
    @State var graphPoints = [CGPoint]()
    let screenRect = UIScreen.main.bounds
    @State var audioPlayer: AVAudioPlayer?
    
    // Test repeat code:
    @State private var count = 0
    @State private var countText = ""
    @State private var running = false
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea(.all)
            VStack {
                let screenWidth = screenRect.size.width
                let screenHeight = screenRect.size.height
                ZStack {
                    Image(.arrow)
                        .resizable()
                        .frame(width: screenWidth, height: 0.194 * screenHeight)
                    Button {
                        // In normal operation pressing this button plays a
                        // sound then starts a test by taking a photo. If
                        // model.repeatTests is true, pressing the button
                        // begins repeated tests (see notes in Text element
                        // below). Pressing it a second time stops the
                        // repeated tests.
                        if model.repeatTests {
                            running = !running
                        } else {
                            playSound()
                            model.camera.takePhoto()
                        }
                    }
                    label: {
                        Label {
                            Text("")
                        } icon: {
                            ZStack {
                                Circle()
                                    .strokeBorder(.white, lineWidth: 3)
                                    .frame(width: 0.194 * screenHeight,
                                           height: 0.194 * screenHeight)
                                Circle()
                                    .fill(.yellow)
                                    .frame(width: 0.176 * screenHeight,
                                           height: 0.176 * screenHeight)
                            }
                        }
                    }
                }
                HStack {
                    Text("SARSIE")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("®")
                        .font(.system(size: 30))
                        .foregroundColor(.white)

                    // This Text element is only visible when model.repeatTests
                    // is true. See notes in DataModel.swift.
                    Text(countText)
                        .onReceive(timer) { _ in
                            if model.repeatTests {
                                if running {
                                    count += 1
                                    countText = "\(count)"
                                    
                                    // Start next test.
                                    playSound()
                                    model.camera.takePhoto()
                                } else {
                                    count = 0
                                    countText = "0"
                                }
                            } else {
                                countText = ""
                            }
                        }
                        .foregroundColor(.white)
                    // End test repeat

                }
                MeterView(width: 0.763 * screenWidth,
                          height: 0.235 * screenHeight,
                          value: model.testResult.value,
                          positiveThreshold: model.virusThreshold)
                
                // Display test value (count & sum returned from VirusTest.test()).
                /*
                Text("\(model.testResult.count) \(model.testResult.sum) \(model.testResult.value)")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                 */
                
                GraphView(width: 0.992 * screenWidth,
                          height: 0.235 * screenHeight, 
                          threshold: model.virusThreshold, points: model.graphPoints)
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
    
    func playSound() {
        let path = Bundle.main.path(forResource: "buttonPush.wav", ofType: nil)
        let url = URL(fileURLWithPath: path!)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not load sound file")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//  Created by Aisultan Askarov on 27.11.2022.
//

import Foundation

import Foundation
import AVFoundation

var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String) {
    if let path = Bundle.main.path(forResource: sound, ofType: type) {
        do {
            if #available(iOS 16.0, *) {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(filePath: path))
            } else {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            }
            audioPlayer?.play()
        } catch {
            print("Could not play the sound file.")
        }
    }
}

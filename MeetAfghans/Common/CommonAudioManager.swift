//
//  CommonAudioManager.swift
//  Sama Contact Lens
//
//  Created by Convergent Infoware on 16/10/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import Foundation
import AVFoundation

class CommonAudioPlayer : NSObject{
    
    static let shared = CommonAudioPlayer()
    var player : AVAudioPlayer?
    lazy var url = Bundle.main.url(forResource: "sound_splash", withExtension: "mp3")
    
    func playAudio() {
        do{
            guard let url = url else {return}
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            // to stop the spound .stop()
        }catch{
            print ("file could not be loaded or other error!")
        }
    }
    
    func stopAudio(){
        fadeVolumeAndPause()
    }
    
    func fadeVolumeAndPause(){
        if self.player?.volume ?? 0 > Float(0.1) {
            self.player?.volume = self.player!.volume - 0.1
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.fadeVolumeAndPause()
            }
        } else {
            self.player?.stop()
            self.player?.volume = 1.0
        }
    }
    
}

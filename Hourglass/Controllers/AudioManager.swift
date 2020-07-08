//
//  AudioManager.swift
//  Hourglass
//
//  Created by Richard Robinson on 2020-07-07.
//

import Foundation
import AVFoundation

class AudioManager: NSObject {
    static let shared = AudioManager()
    
    private var audioSession: AVAudioSession = .sharedInstance()
    private var player: AVAudioPlayer?
    
    func play(_ source: String) {
        guard player == nil,
              let url = Bundle.main.url(forResource: source, withExtension: nil)
        else { return }
        
        try? audioSession.setCategory(.ambient)
        try? audioSession.setActive(true)
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.play()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "no error details provided")
    }
}

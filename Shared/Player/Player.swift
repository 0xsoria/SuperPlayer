//
//  Player.swift
//  SuperPlayer
//
//  Created by Gabriel Sória Souza on 23/06/20.
//

import AudioMachine

protocol Play {
    func setAudioFile(url: URL)
    func getLenghtOfFile() -> Float?
    func playPause()
    func stop()
    func isPlaying() -> Bool
    func seek(to time: Float)
}

final class Player: NSObject, Play {

    static let shared = Player()
    private var player: AMAudioPlayer?
    
    private override init() {
        //play
    }
    
    func setAudioFile(url: URL) {
        self.player = AMAudioPlayer(audioFileURL: url)
        self.player?.audioFileSetup(url)
        self.player?.delegate = self
    }
    
    func getLenghtOfFile() -> Float? {
        if let player = self.player {
            return player.audioLenghtSeconds
        }
        return nil
    }
    
    func playPause() {
        if let player = self.player {
            player.setPlayOrPause()
        }
    }
    
    func stop() {
        if let player = self.player {
            player.stopPlayingAudio()
        }
    }
    
    func isPlaying() -> Bool {
        if let _ = self.player {
            //player.isPlaying()
            return false
        }
        return false
    }
    
    func seek(to time: Float) {
        if let player = self.player {
            player.seek(time)
        }
    }
}

extension Player: AMAudioPlayerDelegate {
    func progressUpdate(withCurrentPosition currentPosition: Float) {
        
    }
    
    func countdownUp(withTime time: String) {
        
    }
    
    func countdownTime(withTime time: String) {
        
    }
    
    func meterLevel(withLevel level: Double) {
        
    }
    
    func didDisconnectVolumeTap() {
        
    }
    
    func setUpdaterToPaused(_ paused: Bool) {
        
    }
}

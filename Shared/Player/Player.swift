//
//  Player.swift
//  SuperPlayer
//
//  Created by Gabriel Sória Souza on 23/06/20.
//

import AudioMachine

protocol Play {
	var currentPosition: Float { get }
	
	func setAudioFile(url: URL)
    func getLenghtOfFile() -> Float?
    func playPause()
    func stop()
    func seek(to time: Float)
}

final class Player: NSObject, Play, ObservableObject {

    static let shared = Player()
    private var player: AMAudioPlayer?
	@Published var currentPosition: Float = 0.0
	@Published var timePlayed = "0:00"
	@Published var timeRemaining = "0:00"
	@Published var metadataContent = [MetadataContent]()
	@Published var isPlaying = false
	
	var rateValue: Float = 1.0 {
		didSet {
			self.player?.rateValue = rateValue
		}
	}
	var rateValues: [Float] = [0.5, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
	var initialRateValue: Float {
		return self.player?.rateValue ?? 1.0
	}
	
    private override init() {
        //play
    }
	
	func updaterToggle() {
		self.player?.updaterPauseToggle()
	}
	
	func showMetadata() {
		if let data = self.player?.getMetadata() as? [String: String] {
			self.metadataContent = self.parseMetadataContent(content: data)
			return
		}
		self.metadataContent = []
	}
	
	private func parseMetadataContent(content: [String: String]) -> [MetadataContent] {
		var temp = [MetadataContent]()
		for i in content {
			temp.append(MetadataContent(key: i.key, value: i.value))
		}
		return temp
	}
	
	func setAudioFile(url: URL) {
		if url != self.player?.fileURL {
			self.player?.stopPlayingAudio()
			self.player = AMAudioPlayer(audioFileURL: url)
			self.player?.delegate = self
		}
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
			self.isPlaying = player.isPlaying()
        }
    }
    
    func stop() {
        if let player = self.player {
            player.stopPlayingAudio()
			self.isPlaying = false
        }
    }
    
    func seek(to time: Float) {
        if let player = self.player {
            player.seek(time)
        }
    }
}

extension Player: AMAudioPlayerDelegate {
    func progressUpdate(withCurrentPosition currentPosition: Float) {
		self.currentPosition = currentPosition
    }
    
    func countdownUp(withTime time: String) {
		self.timePlayed = time
    }
    
    func countdownTime(withTime time: String) {
		self.timeRemaining = time
    }
    
    func meterLevel(withLevel level: Double) {
        
    }
    
    func didDisconnectVolumeTap() {
        
    }
    
    func setUpdaterToPaused(_ paused: Bool) {
        
    }
}

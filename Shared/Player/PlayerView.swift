//
//  PlayerView.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 27/06/20.
//

import SwiftUI

enum PlayerSegment: String {
	case player = "Player"
	case info = "Info"
}

struct PlayerView: View {
	
	@ObservedObject var player: Player
	@State var rateValue: Float = 1.0
	private let file: URL
	@State private var segmentIndex = 0
	@State private var segments: [PlayerSegment] = [.player, .info]
	
	
	init(file: URL, player: Player) {
		self.player = player
		self.file = file
	}
	
	var playerView: some View {
		VStack {
			HStack {
				Button(action: {
					self.backTenSeconds()
				}, label: {
					Image(systemName:
							"gobackward.10")
						.resizable()
						.aspectRatio(contentMode: .fit)
				}).frame(width: 50, height: 50, alignment: .center)
				Button(action: {
					self.playPause()
				}, label: {
					Image(systemName: "play.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(.black)
				}).frame(width: 50, height: 50, alignment: .center)
				Button(action: self.stopPlayback, label: {
					Image(systemName: "stop.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(.black)
				}).frame(width: 50, height: 50, alignment: .center)
				Button(action: {
					self.forwardTenSeconds()
				}, label: {
					Image(systemName:
							"goforward.10")
						.resizable()
						.aspectRatio(contentMode: .fit)
				}).frame(width: 50, height: 50, alignment: .center)
			}.onAppear(perform: {
				self.setupFile(with: file)
			})
			ProgressBar(value: self.player.currentPosition).frame(height: 20)
			HStack {
				Text(self.player.timePlayed)
				Spacer()
				Text(self.player.timeRemaining)
			}
			Slider(value: $rateValue, in: 0.5...3.0, step: 0.25) { _  in
				self.player.rateValue = rateValue
			}
			Text(String(format: "Playback speed: %.2fx", self.rateValue))
		}.padding()
		.onAppear() {
			self.player.updaterToggle()
			self.rateValue = self.player.initialRateValue
		}
	}
	
	var infoView: some View {
		List {
			ForEach(self.player.metadataContent, id: \.self) { item in
				MetadataRow(metadata: item)
			}
		}.onAppear(perform: {
			self.player.updaterToggle()
			self.player.showMetadata()
		})
	}
	
	var body: some View {
		VStack {
			Picker(selection: $segmentIndex, label: Text(""), content: {
				ForEach(0..<self.segments.count) { index in
					Text(self.segments[index].rawValue).tag(index)
				}
			}).pickerStyle(SegmentedPickerStyle())
		}
		if self.segmentIndex == 0 {
			self.playerView
		} else {
			self.infoView
		}
	}
	
	private func stopPlayback() {
		self.player.stop()
	}
	
	private func backTenSeconds() {
		self.player.seek(to: -10.0)
	}
	
	private func forwardTenSeconds() {
		self.player.seek(to: 10.0)
	}
	
	private func setupFile(with url: URL) {
		self.player.setAudioFile(url: url)
	}
	
	private func playPause() {
		self.player.playPause()
	}
}

struct PlayerView_Previews: PreviewProvider {
	static var previews: some View {
		PlayerView(file: URL(string: String())!, player: Player.shared)
	}
}

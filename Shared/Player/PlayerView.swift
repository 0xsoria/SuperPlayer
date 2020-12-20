//
//  PlayerView.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 27/06/20.
//

import SwiftUI

enum PlayerSegment: String, CaseIterable, Identifiable {
	case player = "Player"
	case info = "Info"
	
	var id: String {
		self.rawValue
	}
}

struct PlayerView: View {
	
	@ObservedObject var player: Player
	@State var rateValue: Float = 1.0
	private let file: URL
	@State private var segmentIndex = PlayerSegment.player
	
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
				if !self.player.isPlaying {
					Button(action: {
						self.playPause()
					}, label: {
						Image(systemName: "play.fill")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.foregroundColor(.black)
					}).frame(width: 50, height: 50, alignment: .center)
				} else {
					Button(action: {
						self.playPause()
					}, label: {
						Image(systemName: "pause.fill")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.foregroundColor(.black)
					}).frame(width: 50, height: 50, alignment: .center)
				}
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
			Spacer()
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
			self.player.showMetadata()
			self.player.updaterToggle()
		})
	}
	
	var body: some View {
		VStack {
			Picker(selection: $segmentIndex, label: Text(""), content: {
				ForEach(PlayerSegment.allCases) { index in
					Text(index.rawValue).tag(index)
				}
			}).pickerStyle(SegmentedPickerStyle())
		}
		Spacer()
		if self.segmentIndex == .player {
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

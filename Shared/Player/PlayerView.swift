//
//  PlayerView.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 27/06/20.
//

import SwiftUI

struct PlayerView: View {
	
	@ObservedObject var player: Player
	private let file: URL
	@State var progressValue: Float =  0.0
	
	init(file: URL, player: Player) {
		self.player = player
		self.file = file
	}
	
	var body: some View {
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
					Image(systemName: "play.fill").resizable().aspectRatio(contentMode: .fit)
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
		}.padding()
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

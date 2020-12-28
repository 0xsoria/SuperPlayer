//
//  MiniPlayerView.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 01/07/20.
//

import SwiftUI

struct MiniPlayerView: View {
    
	@EnvironmentObject var player: Player
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
			Button(action: self.backward, label: {
                Image(systemName: "gobackward.10")
                    .resizable().aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
            })
            Spacer()
            Spacer()
			if self.player.isPlaying {
				Button(action: self.play, label: {
					Image(systemName: "pause.fill")
						.resizable().aspectRatio(contentMode: .fit)
						.foregroundColor(.black)
				})
			} else {
				Button(action: self.play, label: {
					Image(systemName: "play.fill")
						.resizable().aspectRatio(contentMode: .fit)
						.foregroundColor(.black)
				})
			}
            Spacer()
            Spacer()
			Button(action: self.forward, label: {
                Image(systemName: "goforward.10")
                    .resizable().aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
                
            })
            Spacer()
        }
        .frame(width: 150, height: 80, alignment: .center)
        .background(Color.blue)
        .cornerRadius(20)
    }
    
    func play() {
		self.player.playPause()
    }
	
	func forward() {
		self.player.seek(to: 10.0)
	}
	
	func backward() {
		self.player.seek(to: -10.0)
	}
}

struct MiniPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerView()
    }
}

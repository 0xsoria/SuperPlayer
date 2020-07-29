//
//  PlayerView.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 27/06/20.
//

import AudioMachine
import SwiftUI

struct PlayerView: View {
    
    private let player: Play
    private let file: URL
    private let amPlayer = AMAudioPlayer()
    
    init(file: URL, player: Play) {
        self.player = player
        self.file = file
        //self.setupFile(with: file)
    }
    
    var body: some View {
        Button(action: {
            self.playPause()
        }, label: {
            Image(systemName: "play.fill").resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
        }).frame(width: 50, height: 50, alignment: .center)
        
    }
    
    func setupFile(with url: URL) {
        //self.player.setAudioFile(url: url)
    }
    
    func playPause() {
        self.amPlayer.audioFileSetup(self.file)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(file: URL(string: String())!, player: Player.shared)
    }
}

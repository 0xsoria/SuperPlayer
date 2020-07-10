//
//  MiniPlayerView.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 01/07/20.
//

import SwiftUI

struct MiniPlayerView: View {
    
    var playPause: () -> Void
    var back: () -> Void
    var forward: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            Button(action: action, label: {
                Image(systemName: "gobackward.10")
                    .resizable().aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
            })
            Spacer()
            Spacer()
            Button(action: action, label: {
                Image(systemName: "play.fill")
                    .resizable().aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
            })
            Spacer()
            Spacer()
            Button(action: action, label: {
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
    
    func action() {
        
    }
}

struct MiniPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerView(playPause: {}, back: {}, forward: {})
    }
}

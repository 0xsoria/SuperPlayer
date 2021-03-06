//
//  FilesView.swift
//  SuperPlayer
//
//  Created by Gabriel Sória Souza on 22/06/20.
//

import Combine
import SwiftUI

struct FilesView: View {
    
    var files: [Track] = []
    var onDelete: ((Int) -> Void)?
	@EnvironmentObject var player: Player
    
    var body: some View {
        Group {
            if self.files.isEmpty {
                Text("Your don't have any file, tap the + button to add a new file").multilineTextAlignment(.center)
            } else {
				FilesList(files: self.files, onDelete: self.onDelete)
					.environmentObject(self.player)
            }
        }
    }
}

struct FilesView_Previews: PreviewProvider {
    static var previews: some View {
        FilesView(files: [])
    }
}

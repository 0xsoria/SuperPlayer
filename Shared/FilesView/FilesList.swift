//
//  FilesList.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 27/06/20.
//

import SwiftUI

struct FilesList: View {
    
    let files: [Track]
    var onDelete: ((Int) -> Void)?
    let player: Player
    
    init(files: [Track], onDelete: ((Int) -> Void)?, player: Player) {
        self.files = files
        self.onDelete = onDelete
        self.player = player
    }
    
    var body: some View {
        List {
            ForEach(self.files, id: \.self) { item in
                NavigationLink(destination: PlayerView(file: item.url, player: self.player)) {
                    FilesRow(fileName: item.name)
                }
            }.onDelete { idx in
                self.delete(index: idx)
            }
        }
    }
    
    func delete(index: IndexSet) {
        for i in index {
            guard let delete = onDelete else {
                return
            }
            delete(i)
        }
    }
}

struct FilesList_Previews: PreviewProvider {
    static var previews: some View {
        FilesList(files: [Track(name: "atp.mp3",
                                artist: "atp",
                                url: URL(string: "")!)],
                  onDelete: nil,
                  player: Player.shared)
    }
}

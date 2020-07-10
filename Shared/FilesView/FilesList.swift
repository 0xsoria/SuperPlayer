//
//  FilesList.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 27/06/20.
//

import SwiftUI

struct FilesList: View {
    
    let files: [URL]
    var onDelete: ((Int) -> Void)?
    let player: Play
    
    init(files: [URL], onDelete: ((Int) -> Void)?, player: Play) {
        self.files = files
        self.onDelete = onDelete
        self.player = player
    }
    
    var body: some View {
        List {
            ForEach(self.files, id: \.self) { item in
                NavigationLink(destination: PlayerView(file: item, player: self.player)) {
                    FilesRow(fileName: "\(item.lastPathComponent)")
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
        FilesList(files: [URL(string: "www.apple.com")!], onDelete: nil, player: Player.shared)
    }
}

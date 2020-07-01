//
//  FilesList.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 27/06/20.
//

import SwiftUI

struct FilesList: View {
    
    let files: [URL]
    
    init(files: [URL]) {
        self.files = files
    }
    
    var body: some View {
        List {
            ForEach(self.files, id: \.self) { items in
                NavigationLink(destination: PlayerView()) {
                    FilesRow(fileName: "\(items.lastPathComponent)")
                }
            }
        }
    }
}

struct FilesList_Previews: PreviewProvider {
    static var previews: some View {
        FilesList(files: [URL(string: "www.apple.com")!])
    }
}

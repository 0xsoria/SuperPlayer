//
//  FilesView.swift
//  SuperPlayer
//
//  Created by Gabriel Sória Souza on 22/06/20.
//

import Combine
import SwiftUI

struct FilesView: View {
    
    //@ObservedObject var fileManager = FilesManager(service: Service())
    var files: [URL] = []
    
    var body: some View {
        Group {
            if self.files.isEmpty {
                Text("Your don't have any file, tap the + button to add a new file").multilineTextAlignment(.center)
            } else {
                FilesList(files: self.files)
            }
        }
    }
}

struct FilesView_Previews: PreviewProvider {
    static var previews: some View {
        FilesView(files: [])
    }
}

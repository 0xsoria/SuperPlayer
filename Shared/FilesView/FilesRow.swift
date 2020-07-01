//
//  FilesRow.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 27/06/20.
//

import SwiftUI

struct FilesRow: View {
    
    let fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "waveform")
            Text(self.fileName)
        }
    }
}

struct FilesRow_Previews: PreviewProvider {
    static var previews: some View {
        FilesRow(fileName: "atp.mp3")
    }
}

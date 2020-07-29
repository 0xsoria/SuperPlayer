//
//  ActiveDownloadsView.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 11/07/20.
//

import SwiftUI

struct ActiveDownloadsView: View {
    
    var downloads: [Download] = []
    var action: (() -> Void)?
    
    var body: some View {
        
        if !self.downloads.isEmpty {
            List {
                ForEach(downloads, id: \.progress) { item in
                    HStack {
                        Text(item.track.name)
                        Spacer()
                        DownloadProgress(download: item)
                    }
                }
            }
        } else {
            Text("No downloads going on")
        }
    }
}

struct ActiveDownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveDownloadsView(downloads: [])
    }
}

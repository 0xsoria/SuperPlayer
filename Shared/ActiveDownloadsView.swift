//
//  ActiveDownloadsView.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 11/07/20.
//

import SwiftUI

struct ActiveDownloadsView: View {
    
	@EnvironmentObject var downloadManager: FilesManager
    var action: (() -> Void)?
    
    var body: some View {
        
        if !self.downloadManager.downloadsInProgress.isEmpty {
            List {
				ForEach(downloadManager.downloadsInProgress, id: \.progress) { item in
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
		ActiveDownloadsView().environmentObject(FilesManager())
    }
}

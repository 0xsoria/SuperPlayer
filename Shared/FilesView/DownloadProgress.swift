//
//  DownloadProgress.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 11/07/20.
//

import SwiftUI

struct DownloadProgress: View {
    
    var download: Download
    
    init(download: Download) {
        self.download = download
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3.0)
                .opacity(0.4)
                .foregroundColor(Color.gray)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.download.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            Text(String(format: "%.0f %%", min(self.download.progress, 1.0)*100.0))
                .font(.caption2)
                .bold()
		}
    }
}

struct DownloadProgress_Previews: PreviewProvider {
    static var previews: some View {
//        DownloadProgress(download: Download(track: Track(name: String(), artist: String(), url: URL(string: String())!)))
		Text("")
    }
}

//
//  MetadataRow.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 06/09/20.
//

import SwiftUI

struct MetadataRow: View {
	
	let metadata: MetadataContent
	
	init(metadata: MetadataContent) {
		self.metadata = metadata
	}
	
    var body: some View {
		HStack(alignment: .center, spacing: 20, content: {
			Text(self.metadata.key)
			Spacer()
			Text(self.metadata.value)
		})
    }
}

struct MetadataRow_Previews: PreviewProvider {
    static var previews: some View {
		MetadataRow(metadata: MetadataContent(key: "Duration", value: "10.0 seconds"))
    }
}

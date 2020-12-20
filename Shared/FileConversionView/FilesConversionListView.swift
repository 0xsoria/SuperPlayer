//
//  FilesConversionListView.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 12/09/20.
//

import SwiftUI

struct FilesConversionListView: View {
	
	let files: [Track]
	var fileSection: (Track) -> Void
	var onDelete: ((Int) -> Void)?
	
    var body: some View {
		List {
			ForEach(self.files, id: \.self) { item in
				FilesRow(fileName: item.name).onTapGesture {
					self.fileSection(item)
				}
			}.onDelete(perform: { idx in
				self.delete(index: idx)
			})
		}
	}
	
	private func delete(index: IndexSet) {
		for i in index {
			guard let delete = onDelete else {
				return
			}
			delete(i)
		}
	}
}

struct FilesConversionListView_Previews: PreviewProvider {
    static var previews: some View {
		FilesConversionListView(files: [], fileSection: { _ in
			//
		})
    }
}

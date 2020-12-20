//
//  FileConversionView.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 12/09/20.
//

import SwiftUI

struct FileConversionView: View {
	
	private let fileManager = FilesManager()
	private var fileConversion: AudioFileConversible = AudioFileConverter()
	@State private var filesViewIsOpen = false
	@State private var fileTitle = "No file selected"
	@State private var pickerSegmentIndex = AudioFileFormats.MP3
	@State private var sampleRateSegmentIndex = AudioFileSampleRate.k44100
	
	var body: some View {
		NavigationView {
			GeometryReader { geo in
				VStack {
					HStack {
						Text("Select a file to be converted")
						Button(action: self.fileSelection, label: {
							Image(systemName: "plus.circle")
						})
					}
					Spacer()
					Text(self.fileTitle).multilineTextAlignment(.center)
					Spacer()
					
					self.pickersView
					
					Spacer()
					
					Button(action: self.convertAndSave, label: {
						Text("Convert and save")
					})
					
					FilesBottomSheetView(isOpen: self.$filesViewIsOpen, maxHeight: geo.size.height * 0.5, content: {
						FilesConversionListView(files: self.fileManager.files, fileSection: { track in
							self.fileSelection(track: track)
						}, onDelete: { index in
							self.onDeleteFiles(index: index)
						})
					})
				}
			}
		}.onAppear(perform: {
			self.fileManager.loadFiles()
		})
	}
	
	var pickersView: some View {
		VStack {
			Text("Format to convert")
			Picker("Format to convert", selection: self.$pickerSegmentIndex) {
				ForEach(AudioFileFormats.allCases) { format in
					Text(format.rawValue).tag(format)
				}
			}
			Text("Output sample rate")
			Picker("Select the sample rate for your output audio file", selection: self.$sampleRateSegmentIndex) {
				ForEach(AudioFileSampleRate.allCases) { sampleRate in
					Text(String(sampleRate.rawValue)).tag(sampleRate)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}
	}
	
	private func convertAndSave() {
		self.fileConversion.convert(to: .MP3)
	}
	
	private func fileSelection(track: Track) {
		self.fileConversion.selectFile(track: track)
		self.filesViewIsOpen.toggle()
		self.fileTitle = "File to be converted: \(track.name)"
	}
	
	private func onDeleteFiles(index: Int) {
		self.fileManager.deleteFilesAt(index: index)
	}
	
	private func fileSelection() {
		self.filesViewIsOpen.toggle()
	}
}

struct FileConversionView_Previews: PreviewProvider {
	static var previews: some View {
		FileConversionView()
	}
}

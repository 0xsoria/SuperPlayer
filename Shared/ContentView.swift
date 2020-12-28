//
//  ContentView.swift
//  Shared
//
//  Created by Gabriel Sória Souza on 22/06/20.
//

import SwiftUI

struct ContentView: View {
	
	@State private var showingSheet = false
	@State private var alert = false
	@State private var offset = CGSize.zero
	@ObservedObject var fileManager = FilesManager()
	@GestureState private var isDragging = false
	@State private var showingBottomSheet = false
	private let player = Player.shared
	@State private var downloadsViewIsShowing = false
	
	var drag: some Gesture {
		DragGesture().onChanged { changed in
			print("offset \(offset)")
			offset = changed.translation
			print("changed to \(changed.translation)")
		}
		.onEnded { onEnded in
			offset = onEnded.translation
		}
		.updating($isDragging) { (changed, state, transaction) in
			//print(changed)
			//print(state)
			//print((transaction))
		}
	}
	
	var body: some View {
		NavigationView {
			GeometryReader { geo in
				ZStack {
					FilesView(files: self.fileManager.files) { idx in
						self.onDeleteFiles(index: idx)
					}.environmentObject(self.player)
					MiniPlayerView().environmentObject(self.player)
						.offset(offset)
						.gesture(drag)
						.onAppear {
							offset = CGSize(width: (geo.size.width / 3.5),
											height: (geo.size.height / 2.5))
						}
					FilesBottomSheetView(isOpen: self.$downloadsViewIsShowing,
										 maxHeight: geo.size.height * 0.5,
										 content: {
											ActiveDownloadsView().environmentObject(self.fileManager)
										 })
				}
			}
			.navigationBarTitle("Your Files", displayMode: .large)
			.navigationBarItems(leading:
									Button(action: self.showDownloads, label: {
										Image(systemName: "square.and.arrow.down.fill")
									}),trailing:
										Button(action: self.showBottomSheet,
										   label: { Image(systemName: "plus.circle") }))
		}
		.actionSheet(isPresented: $showingSheet) {
			ActionSheet(title: Text("Add your files"), message: nil, buttons: [.default(Text("Download a file from URL"), action: {
				self.showAlertWithTextField(with: "Download your audio file",
											message: nil,
											placeholder: "File URL",
											actionTitle: "Download",
											cancelTitle: "Cancel") { url in
					self.download(fileURL: url)
					self.showingBottomSheet.toggle()
				}
			}), .cancel(Text("Cancel"))])
		}
		.onAppear {
			self.fileManager.loadFiles()
		}
		.alert(isPresented: $alert) {
			Alert(title: Text("This is not an audio file!"), message: Text("Please place an valid URL"), dismissButton: .default(Text("OK")))
		}
	}
	
	func showBottomSheet() {
		self.showingSheet = true
		if self.showingBottomSheet {
			self.showingBottomSheet.toggle()
		}
	}
	
	func showDownloads() {
		self.downloadsViewIsShowing.toggle()
	}
	
	func onDeleteFiles(index: Int) {
		self.fileManager.deleteFilesAt(index: index)
	}
	
	func download(fileURL: String) {
		self.fileManager.downloadFileFromService(urlString: fileURL)
	}
	
	func fetchFiles() {
		self.fileManager.loadFiles()
	}
	
	func addFiles() {
		self.showingSheet = true
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.previewDevice("iPhone 11 Pro Max")
	}
}

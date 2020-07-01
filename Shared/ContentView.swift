//
//  ContentView.swift
//  Shared
//
//  Created by Gabriel Sória Souza on 22/06/20.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var showingSheet = false
    @State private var alert = false
    @ObservedObject var fileManager = FilesManager(service: Service())
    
    var body: some View {
        NavigationView {
            TabView {
                FilesView(files: self.fileManager.files)
            }
            .navigationBarTitle("Your Files", displayMode: .large)
            .navigationBarItems(trailing:
                                    Button(action: { self.showingSheet = true }, label: {
                Image(systemName: "plus.circle")
            }))
        }
        .actionSheet(isPresented: $showingSheet) {
            ActionSheet(title: Text("Add your files"), message: nil, buttons: [.default(Text("Download a file from URL"), action: {
                self.showAlertWithTextField(with: "Download your audio file", message: nil, placeholder: "File URL", actionTitle: "Download", cancelTitle: "Cancel") { url in
                    self.download(fileURL: url)
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
    
    func download(fileURL: String) {
        if let url = URL(string: fileURL) {
            if url.pathExtension == "mp3" {
                self.fileManager.downloadFileFromService(urlString: fileURL)
            } else {
                self.alert.toggle()
            }
        } else {
            self.alert.toggle()
        }
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
    }
}

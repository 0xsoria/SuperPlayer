//
//  FileConversion.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 12/09/20.
//

import AudioMachine
import AVFoundation

protocol AudioFileConversible {
	var convertedTrack: Track? { get set }
	
	func selectFile(track: Track)
	func convert(to format: AudioFileFormats)
}

final class AudioFileConverter: NSObject, AudioFileConversible, ObservableObject {
	
	@Published var convertedTrack: Track?
	private var trackToBeConverted: Track? = nil
	private var converter: AMAudioFileConverter?
	
	func selectFile(track: Track) {
		self.trackToBeConverted = track
	}
	
	
	
	func convert(to format: AudioFileFormats) {
		guard let track = self.trackToBeConverted, let userFolder = FilesManager.savingFolder() else { return }
		
		let fileNameWithoutFormat = track.url.deletingPathExtension()
		let fileWithFormat = fileNameWithoutFormat.appendingPathExtension(format.rawValue)
		
		self.converter = AMAudioFileConverter(sourceURL: track.url,
											  destinationURL: fileWithFormat,
											  sampleRate: 44100.0,
											  outputFormat: self.convertToCAFormat(format: .MP3))
		self.converter?.delegate = self
		
		
		DispatchQueue.global(qos: .userInteractive).async { [weak self] in
			self?.converter?.startConverting()
		}
	}
}

extension AudioFileConverter {
	func convertToCAFormat(format: AudioFileFormats) -> AudioFormatID {
		switch format {
		case .AAC:
			return kAudioFormatMPEG4AAC
		case .MP3:
			return kAudioFormatMPEGLayer3
		case .ALAC:
			return kAudioFormatAppleLossless
		}
	}
}

extension AudioFileConverter: AMAudioFileConverterDelegate {
	func audioFileConvertOperation(_ audioFileConvertOperation: AMAudioFileConverter, didEncounterError error: Error) {
		print(error)
	}
	
	func audioFileConvertOperation(_ audioFileConvertOperation: AMAudioFileConverter, didCompleteWith destinationURL: URL) {
		print(destinationURL)
	}
}

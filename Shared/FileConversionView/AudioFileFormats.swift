//
//  AudioFileFormats.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 13/09/20.
//

import Foundation

enum AudioFileFormats: String, CaseIterable, Identifiable {
	case AAC
	case MP3
	case ALAC
	
	var id: String {
		self.rawValue
	}
}

enum AudioFileSampleRate: Float64, CaseIterable, Identifiable {
	case k44100 = 44100.0
	case k22050 = 22050.0
	case k8000 = 8000.0
	
	var id: Float64 {
		self.rawValue
	}
}

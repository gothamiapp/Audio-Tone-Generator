//
//  WaveformType.swift
//  Audio Tone Generator
//
//  Created by user279042 on 8/30/25.
//

import Foundation

enum WaveformType: String, CaseIterable, Identifiable {
    case sine = "Sine"
    case square = "Square"
    case sawtooth = "Sawtooth"
    case triangle = "Triangle"
    
    var id: String { self.rawValue }
}

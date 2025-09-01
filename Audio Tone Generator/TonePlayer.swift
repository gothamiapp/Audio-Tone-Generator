//
//  TonePlayer.swift
//  Audio Tone Generator
//
//  Created by user279042 on 8/30/25.
//
import AVFoundation

class TonePlayer: ObservableObject {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var buffer: AVAudioPCMBuffer?
    
    init() {
        engine.attach(player)
        let format = engine.outputNode.inputFormat(forBus: 0)
        engine.connect(player, to: engine.outputNode, format: format)
        try? engine.start()
    }
    
    func generateBuffer(frequency: Float, waveform: WaveformType, duration: Float = 1.0, sampleRate: Double = 44100.0) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(sampleRate * Double(duration))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let data = buffer.floatChannelData![0]

        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / Float(sampleRate)
            let angle = 2.0 * Float.pi * frequency * time

            switch waveform {
            case .sine:
                data[frame] = sin(angle)
            case .square:
                data[frame] = sin(angle) > 0 ? 1 : -1
            case .sawtooth:
                data[frame] = 2 * (time * frequency - floor(0.5 + time * frequency))
            case .triangle:
                data[frame] = abs(4 * (time * frequency - floor(time * frequency + 0.5))) - 1
            }
        }

        return buffer
    }
    
    func play(frequency: Float, waveform: WaveformType, volume: Float) {
        stop()
        let buffer = generateBuffer(frequency: frequency, waveform: waveform)
        player.volume = volume
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        engine.mainMixerNode.outputVolume = volume
        engine.attach(player)
        engine.connect(player, to: engine.outputNode, format: buffer.format)
        player.play()
    }
    
    func stop() {
        if player.isPlaying {
            player.stop()
        }
    }
}


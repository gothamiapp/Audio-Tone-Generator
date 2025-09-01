import AVFoundation

class TonePlayer: ObservableObject {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    
    init() {
        // Configure audio session
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("⚠️ Failed to activate audio session: \(error)")
        }

        // Attach & connect player
        engine.attach(player)
        let format = engine.outputNode.inputFormat(forBus: 0)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        // Start engine
        do {
            try engine.start()
        } catch {
            print("⚠️ Failed to start engine: \(error)")
        }
    }

    /// Generates a waveform buffer matching the output format (e.g., stereo)
    func generateBuffer(frequency: Float, waveform: WaveformType, duration: Float = 1.0) -> AVAudioPCMBuffer? {
        let format = engine.outputNode.inputFormat(forBus: 0)
        let sampleRate = Float(format.sampleRate)
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("❌ Failed to create buffer")
            return nil
        }

        buffer.frameLength = frameCount
        let channels = Int(format.channelCount)

        for channel in 0..<channels {
            let data = buffer.floatChannelData?[channel]
            for frame in 0..<Int(frameCount) {
                let time = Float(frame) / sampleRate
                let angle = 2.0 * Float.pi * frequency * time

                switch waveform {
                case .sine:
                    data?[frame] = sin(angle)
                case .square:
                    data?[frame] = sin(angle) > 0 ? 1.0 : -1.0
                case .sawtooth:
                    data?[frame] = 2.0 * (time * frequency - floor(0.5 + time * frequency))
                case .triangle:
                    data?[frame] = abs(4.0 * (time * frequency - floor(time * frequency + 0.5))) - 1.0
                }
            }
        }

        return buffer
    }

    func play(frequency: Float, waveform: WaveformType, volume: Float) {
        stop()

        guard let buffer = generateBuffer(frequency: frequency, waveform: waveform) else {
            return
        }

        player.volume = volume
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        
        if !engine.attachedNodes.contains(player) {
            engine.attach(player)
        }

        let format = engine.outputNode.inputFormat(forBus: 0)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        player.play()
    }
//
    func stop() {
        if player.isPlaying {
            player.stop()
        }
    }
}

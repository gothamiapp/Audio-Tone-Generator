import SwiftUI

struct ContentView: View {
    @State private var frequency: Float = 440.0
    @State private var volume: Float = 0.5
    @State private var selectedWaveform: WaveformType = .sine
    @State private var isPlaying = false
    @ObservedObject var player = TonePlayer()
    @State private var coarseFreq: Float = 440
    @State private var fineFreq: Float = 0
    
    
    var totalFrequency: Float {
        max(20000, min(20, coarseFreq + fineFreq))
    }
    
    @State private var pulseHeights: [CGFloat] = Array(repeating: 10, count: 30)
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.orange, Color.orange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
//            VStack(spacing: 20) {
//                Text("Audio Tone Generator")
//                    .font(.largeTitle)
//                    .foregroundColor(.black)
            VStack(spacing: 10) {
            VStack(spacing: 4) {
            Text("Audio Tone Generator")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.black)
            Text("Professional Waveform Synthesis")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.gray)
            }
                
//                SpectrumVisualizerView(powerLevels: $pulseHeights)
//                SpectrumVisualizerView(waveform: selectedWaveform)
                SpectrumVisualizerView(waveform: selectedWaveform, frequency: Int(coarseFreq + fineFreq))
                    .frame(height: 80)
                
                Text("Frequency ")
                    .foregroundColor(.black)
                Text("\(Int(coarseFreq + fineFreq)) Hz")
                    .foregroundColor(.black)

                HStack(spacing: 50) {
                    KnobControl(
                        value: $coarseFreq,
                        title: "Coarse",
                        range: 20...20000,
                        step: 100,
                        stepCount: 10
                    )
                    KnobControl(
                        value: $fineFreq,
                        title: "Fine",
                        range: 0...1000,
                        step: 5,
                        stepCount: 10
                    )
                }
                    // Volume Slider
                    VStack {
                        Text("Volume: \(Int(volume * 100))%")
                            .foregroundColor(.white)
                        Slider(value: $volume)
                            .accentColor(.black)
                            .padding(.horizontal)
                    }
                    
                    // Waveform Picker
//                    Picker("Waveform", selection: $selectedWaveform) {
//                        ForEach(WaveformType.allCases) { wave in
//                            Text(wave.rawValue).tag(wave)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                    .padding()
                VStack(alignment: .leading, spacing: 10) {
                                    Text("Waveform")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.black)
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                        ForEach(WaveformType.allCases) { waveform in
                                            Button(action: {
                                                selectedWaveform = waveform
                                            }) {
                                                VStack(spacing: 4) {
                                                    Image(systemName: icon(for: waveform))
                                                        .font(.system(size: 28))
                                                        .foregroundColor(selectedWaveform == waveform ? .red : .gray)
                                                    Text(waveform.rawValue)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(selectedWaveform == waveform ? .red : .gray)
                                                }
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(selectedWaveform == waveform ? Color.black.opacity(0.2) : Color.black.opacity(0.05))
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(selectedWaveform == waveform ? Color.black : Color.white.opacity(0.2), lineWidth: 2)
                                                )
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                
                
                    
                    // Control Buttons
                    HStack {
                        Button {
                            if isPlaying {
                                player.stop()
                            } else {
                                player.play(frequency: frequency, waveform: selectedWaveform, volume: volume)
                            }
                            isPlaying.toggle()
                        } label: {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 30))
                                .padding()
                                .background(Circle().fill(isPlaying ? Color.red : Color.green))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
        
            .onAppear {
                // Simulate animated spectrum
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    pulseHeights = pulseHeights.map { _ in CGFloat.random(in: 10...60) }
                }
            }
        }
        private func icon(for waveform: WaveformType) -> String {
            switch waveform {
            case .sine: return "waveform.path"
            case .square: return "square.fill"
            case .sawtooth: return "triangle"
            case .triangle: return "triangle.fill"
            }
        }
    }


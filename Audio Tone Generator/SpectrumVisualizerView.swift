//
//  SpectrumVisualizerView.swift
//  Audio Tone Generator
//
//  Created by user279042 on 8/30/25.
//

//import SwiftUI
//
//struct SpectrumVisualizerView: View {
//    @Binding var powerLevels: [CGFloat]
//    
//    var body: some View {
//        HStack(spacing: 2) {
//            ForEach(0..<powerLevels.count, id: \.self) { i in
//                Capsule()
//                    .fill(Color.cyan)
//                    .frame(width: 4, height: powerLevels[i])
//            }
//        }
//        .padding()
//        .background(Color.black.opacity(0.2))
//        .cornerRadius(10)
//    }
//}

import SwiftUI

//struct SpectrumVisualizerView: View {
//    var waveform: WaveformType
//    let width: CGFloat = 350
//    let height: CGFloat = 100
//    let sampleCount: Int = 100
struct SpectrumVisualizerView: View {
        var waveform: WaveformType
        var frequency: Int
        let height: CGFloat = 100


    var sampleCount: Int {
    max(40, min(500, (frequency / 10))) // Clamp for visual clarity
    }

    var body: some View {
        Canvas { context, size in
            let midY = size.height / 2
            let stepX = size.width / CGFloat(sampleCount)
            let cycles = Double(frequency) / 200.0  // tweak 200 to control visual scale

            var path = Path()
            path.move(to: CGPoint(x: 0, y: midY))

            for i in 0..<sampleCount {
                let x = CGFloat(i) * stepX
                let t = Double(i) / Double(sampleCount) * cycles
                let y = midY + waveformY(t: t) * midY * 0.8
                path.addLine(to: CGPoint(x: x, y: y))
            }

            context.stroke(path, with: .color(.yellow), lineWidth: 3)
        }

        .frame(height: height)
        .background(Color.black.opacity(0.8))
        .cornerRadius(10)
    }

    private func waveformY(t: Double) -> CGFloat {
        switch waveform {
        case .sine:
            return CGFloat(sin(2 * .pi * t))
        case .square:
            return CGFloat(sin(2 * .pi * t) >= 0 ? 1 : -1)
        case .sawtooth:
            return CGFloat(2 * (t - floor(t + 0.5)))
        case .triangle:
            return CGFloat(2 * abs(2 * (t - floor(t + 0.5))) - 1)
        }
    }
}

import SwiftUI

struct KnobControl: View {
    @Binding var value: Float
    let title: String
    let range: ClosedRange<Float>
    let step: Float
    let stepCount: Int

    @State private var totalSteps: Int = 0 // Tracks multi-revolution state
    @State private var angle: Double = 0.0
    @GestureState private var isDragging = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.8), lineWidth: 4)
                    .frame(width: 100, height: 100)

                // Tick marks
                ForEach(0..<stepCount, id: \.self) { i in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: 8)
                        .offset(y: -50)
                        .rotationEffect(.degrees(Double(i) * (360.0 / Double(stepCount))))
                }

                // Dot
                Circle()
                    .fill(Color.black)
                    .frame(width: 10, height: 10)
                    .offset(y: -45)
                    .rotationEffect(.degrees(angle))
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let knobCenter = CGPoint(x: 50, y: 50)
                        let loc = gesture.location
                        let dx = loc.x - knobCenter.x
                        let dy = loc.y - knobCenter.y
                        let angleInRadians = atan2(dy, dx)

                        let stepAngle = 2 * .pi / CGFloat(stepCount)
                        let currentStepIndex = Int(round(angleInRadians / stepAngle))

                        if !isDragging {
                            let initialTotalSteps = Int(round((value - range.lowerBound) / step))
                            totalSteps = initialTotalSteps
                        }

                        let stepDelta = normalizeStep(currentStepIndex - (totalSteps % stepCount))
                        totalSteps += stepDelta

                        // Compute new value
                        let rawValue = Float(totalSteps) * step + range.lowerBound
                        value = min(max(rawValue, range.lowerBound), range.upperBound)

                        // Update visual angle
                        angle = Double((totalSteps % stepCount)) * (360.0 / Double(stepCount))
                    }
                    .updating($isDragging) { _, state, _ in state = true }
            )

            Text(title)
                .foregroundColor(.white)
                .font(.footnote)
        }
        .frame(width: 120, height: 150)
    }

    private func normalizeStep(_ delta: Int) -> Int {
        if delta > stepCount / 2 {
            return delta - stepCount
        } else if delta < -stepCount / 2 {
            return delta + stepCount
        }
        return delta
    }
}

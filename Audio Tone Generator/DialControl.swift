import SwiftUI

struct DialControl: View {
    let title: String
    @Binding var value: Float
    let step: Float

    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(.white)
            Slider(value: Binding(get: {
                value
            }, set: { newValue in
                value = newValue
            }), in: 20...2000, step: step)
                .rotationEffect(.degrees(-90))
                .frame(height: 120)
                .padding()
        }
    }
}

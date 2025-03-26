//
//  BMIGaugeView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 26.03.2025.
//


import SwiftUI

struct BMIGaugeView: View {
    let bmi: Double
    let bmiColor: Color
    let bmiText: String

    var body: some View {
        ZStack {
            // MARK: Gauge Arc Background
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height)
                let radius = size.width / 2.2
                let thickness: CGFloat = 12
                let startAngle: Angle = .degrees(180)
                let _: Angle = .degrees(0)

                // Define BMI ranges
                let ranges: [(range: ClosedRange<Double>, color: Color)] = [
                    (15.0...18.5, .orange),
                    (18.6...24.9, .green),
                    (25.0...29.9, .orange),
                    (30.0...32.5, .red)
                ]

                let arcPadding: Double = 0.015 // Adjust this to increase/decrease gap

                for (range, color) in ranges {
                    let totalSpan = 32.5 - 15.0
                    let start = (range.lowerBound - 15.0) / totalSpan + arcPadding
                    let end = (range.upperBound - 15.0) / totalSpan - arcPadding

                    let arc = Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: startAngle + .degrees(180 * start),
                            endAngle: startAngle + .degrees(180 * end),
                            clockwise: false
                        )
                    }
                    let strokeStyle = StrokeStyle(lineWidth: thickness, lineCap: .round)
                    context.stroke(arc, with: .color(color), style: strokeStyle)
                }

                // MARK: Pointer
                let pointerPos = (bmi - 15.0) / (32.5 - 15.0)
                let angle = startAngle + .degrees(180 * pointerPos)
                let pointerX = center.x + cos(angle.radians) * radius
                let pointerY = center.y + sin(angle.radians) * radius

                // Pointer circle exactly on arc path
                let pointer = Path(ellipseIn: CGRect(x: pointerX - 12, y: pointerY - 12, width: 24, height: 24))
                context.fill(pointer, with: .color(bmiColor))
            }
            .frame(height: 180)

            // MARK: Labels
            VStack(spacing: 4) {
                Text(bmiText)
                    .font(.title2)
                    .foregroundStyle(bmiColor)
                Text("BMI")
                    .foregroundColor(.gray)
                Text(String(format: "%.1f", bmi))
                    .font(.largeTitle)
                    .foregroundStyle(bmiColor)
            }
            .offset(y: 50)
        }
    }
}

#Preview {
    BMIGaugeView(bmi: 20.0, bmiColor: .green, bmiText: "Normal")
}

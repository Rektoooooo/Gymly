//
//  RadarLabels.swift
//  Gymly
//
//  Created by Sebastián Kučera on 24.09.2024.
//

import SwiftUI

struct RadarLabels: View {
    var body: some View {
        ZStack {
            Text("Chest")
                .position(x: 130, y: 5)
            Text("Back")
                .position(x: 5, y: 90)
            Text("Biceps")
                .position(x: 5, y: 240)
            Text("Triceps")
                .position(x: 130, y: 330)
            Text("Legs")
                .position(x: 260, y: 305)
            Text("Abs")
                .position(x: 340, y: 160)
            Text("Shoulders")
                .position(x: 270, y: 30)
        }
    }
}

#Preview {
    RadarLabels()
}


struct RadarBackground: Shape {
    var levels: Int

    func path(in rect: CGRect) -> Path {
        let sides = 7
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()
        
        for level in 1...levels {
            let currentRadius = radius * CGFloat(level) / CGFloat(levels)
            
            for i in 0..<sides {
                let angle = (Double(i) / Double(sides)) * 2 * .pi
                let x = center.x + CGFloat(cos(angle)) * currentRadius
                let y = center.y + CGFloat(sin(angle)) * currentRadius
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            path.closeSubpath()
        }
        
        return path
    }
}

struct RadarChart: Shape {
    var values: [Double]
    var maxValue: Double

    func path(in rect: CGRect) -> Path {
        let sides = 7
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        
        for i in 0..<sides {
            let angle = (Double(i) / Double(sides)) * 2 * .pi
            let value = values[i] / maxValue
            let x = center.x + CGFloat(cos(angle)) * radius * CGFloat(value)
            let y = center.y + CGFloat(sin(angle)) * radius * CGFloat(value)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

//
//  ContentViewGraph.swift
//  Gymly
//
//  Created by Sebastián Kučera on 24.09.2024.
//

import SwiftUI

struct ContentViewGraph: View {
    let dataValues = [1.0, 1.0, 6.0, 4.0, 5.5, 6.0, 5.0] // Abs,Legs,Triceps,Biceps,Back,Chest,Shoulders
    let maxValue = 6.0 // Maximum value
        
        var body: some View {
            ZStack {
                RadarBackground(levels: 3)
                    .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.5)
                
                RadarChart(values: dataValues, maxValue: maxValue)
                    .fill(Color.red.opacity(0.4))
                    .overlay(
                        RadarChart(values: dataValues, maxValue: maxValue)
                            .stroke(Color.red, lineWidth: 2)
                    )
            }
            .frame(width: 250, height: 250)
            .padding()
        }
}


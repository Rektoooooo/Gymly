//
//  ContentViewGraph.swift
//  Gymly
//
//  Created by Sebastián Kučera on 24.09.2024.
//

import SwiftUI

struct ContentViewGraph: View {
    @EnvironmentObject var config: Config
        var body: some View {
            ZStack {
                RadarBackground(levels: 3)
                    .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.5)
                
                RadarChart(values: config.graphDataValues, maxValue: config.graphMaxValue)
                    .fill(Color.red.opacity(0.4))
                    .overlay(
                        RadarChart(values: config.graphDataValues, maxValue: config.graphMaxValue)
                            .stroke(Color.red, lineWidth: 2)
                    )
            }
            .onAppear {
                debugPrint(config.graphDataValues)
            }
            .frame(width: 250, height: 250)
            .padding()
        }
}



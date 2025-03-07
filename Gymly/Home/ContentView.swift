//
//  ContentView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            // TODO: Make the graph function with real data
            ZStack {
                ContentViewGraph()
                RadarLabels()
            }
            .frame(maxWidth: 100, maxHeight: 100)
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

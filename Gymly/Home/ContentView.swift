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
            ZStack {
                ContentViewGraph()
                RadarLabels()
            }
            .frame(maxWidth: 100, maxHeight: 100) // Allow full expansion
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

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
            .frame(width: 300, height: 300)
            .navigationTitle("Home")
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

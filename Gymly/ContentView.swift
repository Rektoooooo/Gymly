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
            VStack {
                Image(systemName: "house.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Home")
            }
            .navigationTitle("Home")
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

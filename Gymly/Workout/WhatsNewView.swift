//
//  WhatsNewView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 25.03.2025.
//

import SwiftUI

struct WhatsNewView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List {
                Section("New features in build \(WhatsNewManager.currentBuild)") {
                    Label("New radar graph to show what muscle groups you exercise most you can find in user profile", systemImage: "speedometer")
                    Label("See whats your BMI with new label in your user profile", systemImage: "heart")
                    Label("Track how much weight did u gain or lost with new label in user profile", systemImage: "heart")
                }
                Section("Fixes") {
                    Label("Coping exercises fixed", systemImage: "hammer.fill")
                    Label("Glitches and other bugs fixed", systemImage: "hammer.fill")
                    Label("Importing splits via imessage fixed", systemImage: "hammer.fill")
                }
                Section("") {
                    Button("Got it!") {
                        WhatsNewManager.markAsSeen()
                        isPresented = false
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("What's new?")
        }
    }
}

#Preview {
    @Previewable @State var show = true
    return WhatsNewView(isPresented: $show)
}

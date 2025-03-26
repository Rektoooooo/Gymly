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
                Section("New features") {
                    Label("New graph from displaying body weight history, just click on the weight label in setting", systemImage: "arrow.clockwise")
                    Label("New graph and labels for bmi calculation, just click on the bmi label in settings", systemImage: "arrow.clockwise")
                }
                Section("Fixes") {
                    Label("Fixed UI refreshing bugs", systemImage: "hammer.fill")
                    Label("Fixed writing data into Apple HealtKit", systemImage: "hammer.fill")
                }
                Section("") {
                    Button("Got it!") {
                        WhatsNewManager.markAsSeen()
                        isPresented = false
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("What's new in build \(WhatsNewManager.currentBuild)")
        }
    }
}

#Preview {
    @Previewable @State var show = true
    return WhatsNewView(isPresented: $show)
}

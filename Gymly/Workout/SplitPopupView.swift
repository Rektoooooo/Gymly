//
//  SplitPopupView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 16.01.2025.
//

import SwiftUI
import SwiftData

struct SplitPopupView: View {
    
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) var context: ModelContext
    
    @State var showSplit: Bool = false
    @State var showWholeSplit: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("You haven't set up your gym split yet.")
                Button("Set up split!") {
                    showSplit.toggle()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .padding()
            }
        }
        .sheet(isPresented: $showSplit, onDismiss: {
            showWholeSplit.toggle()
        }) {
            SetupSplitView(viewModel: viewModel)
                .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $showWholeSplit, onDismiss: {

        } ,content: {
            SplitView(viewModel: viewModel)
            
            })
        
    }
}

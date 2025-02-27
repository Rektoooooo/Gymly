//
//  SplitsView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 27.02.2025.
//

import SwiftUI
import SwiftData

struct SplitsView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) var context: ModelContext
    @State var splits: [Split] = []
    @State var createSplit: Bool = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            List {
                ForEach(splits) { split in
                    NavigationLink(destination: SplitDetailView(split: split, viewModel: viewModel)) {
                        VStack {
                            HStack {
                                Text(split.name)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            HStack {
                                if split.isActive {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Active")
                                        .foregroundStyle(Color.green)
                                        .multilineTextAlignment(.leading)
                                    
                                } else {
                                    Text("Inactive")
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                        .foregroundStyle(Color.red)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding(.vertical)
            .navigationTitle("My Splits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createSplit = true
                    } label: {
                        Label("", systemImage: "plus.circle")
                    }
                }
            }
        }
        .task {
            splits = viewModel.getAllSplits(context: context)
        }
        .sheet(isPresented: $createSplit, onDismiss: {
            
        }) {
            SetupSplitView(viewModel: viewModel)
                .presentationDetents([.fraction(0.5)])
        }
    }
}

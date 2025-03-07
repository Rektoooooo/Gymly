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
    @Environment(\.dismiss) private var dismiss
    @State var splits: [Split] = []
    @State var createSplit: Bool = false
    var body: some View {
        NavigationView {
            // TODO: Make switching between split possible
            List {
                /// Show all splits
                ForEach(splits) { split in
                    NavigationLink(destination: SplitDetailView(split: split, viewModel: viewModel)) {
                        VStack {
                            /// Display split name
                            HStack {
                                Text(split.name)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            /// Display graphic if split is active or not
                            HStack {
                                if split.isActive {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Active")
                                        .foregroundStyle(Color.green)
                                        .multilineTextAlignment(.leading)
                                } else {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                    Text("Inactive")
                                        .foregroundStyle(Color.red)
                                        .multilineTextAlignment(.leading)
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
                /// Button for adding splits
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

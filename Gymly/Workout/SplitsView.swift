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
    @Environment(\.colorScheme) var scheme

    @State var splits: [Split] = []
    @State var createSplit: Bool = false
    var body: some View {
        NavigationView {
            // TODO: Make switching between split possible
            ZStack {
                FloatingClouds(theme: CloudsTheme.graphite(scheme))
                    .ignoresSafeArea()
                List {
                    /// Show all splits
                    ForEach($splits.sorted(by: { $0.wrappedValue.isActive && !$1.wrappedValue.isActive })) { $split in
                        NavigationLink(destination: SplitDetailView(split: split, viewModel: viewModel)) {
                            VStack {
                                HStack {
                                    HStack {
                                        Toggle("", isOn: $split.isActive)
                                            .toggleStyle(CheckToggleStyle())
                                            .onChange(of: split.isActive) {
                                                if split.isActive {
                                                    viewModel.switchActiveSplit(split: split, context: context)
                                                }
                                            }
                                        
                                    }
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
                        .swipeActions(edge: .trailing) {
                            /// Swipe-to-delete action
                            Button(role: .destructive) {
                                viewModel.deleteSplit(split: split)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .listRowBackground(Color.black.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listRowBackground(Color.clear)
                .navigationTitle("My Splits")
                .padding(.vertical)
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
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.importSplit)) { notification in
            if let split = notification.object as? Split {
                print("📩 Received imported split notification: \(split.name)")
                
                DispatchQueue.main.async {
                    viewModel.deactivateAllSplits()
                    splits = viewModel.getAllSplits() // Reload all splits from database
                }
            }
        }
        .task {
            splits = viewModel.getAllSplits()
        }
        .sheet(isPresented: $createSplit, onDismiss: {
            
        }) {
            SetupSplitView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
    }
    /// Toggles set type and saves changes
    struct CheckToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            Button {
                configuration.isOn.toggle()
            } label: {
                Label {
                    configuration.label
                } icon: {
                    Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                        .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                        .imageScale(.large)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

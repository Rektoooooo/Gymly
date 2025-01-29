//
//  TodayWorkoutView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 20.08.2024.
//

import SwiftUI
import Foundation
import SwiftData

struct TodayWorkoutView: View {
    
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var config: Config
    @Environment(\.modelContext) var context: ModelContext
    @State var showProfileView: Bool = false
    
    @State private var navigationTitle: String = ""
    @State var muscleGroups:[MuscleGroup] = []
    
    var body: some View {
        NavigationView{
            VStack {
                List {
                    ForEach(muscleGroups) { group in
                        if !group.exercises.isEmpty {
                            Section(header: Text(group.name)) {
                                ForEach(group.exercises, id: \.id) { exercise in
                                    NavigationLink(destination: ExerciseDetailView(viewModel: viewModel, exercise: exercise)) {
                                        Text(exercise.name)
                                    }
                                }
                            }
                        }
                    }
                    Section("") {
                        Button("Workout done") {
                            Task {
                                await viewModel.insertWorkout()
                            }
                        }
                    }
                }
                .id(UUID())
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.large)
                .onChange(of: viewModel.addExercise) {
                    Task {
                        await refreshMuscleGroups()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            showProfileView = true
                        }) {
                            if let imagePath = config.userProfileImageURL {
                                if imagePath == "defaultProfileImage" {
                                    Image("defaultProfileImage") // Load from Assets
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                                } else {
                                    let fileURL = URL(fileURLWithPath: imagePath.replacingOccurrences(of: "file://", with: "")) // Fix local file path
                                    
                                    if FileManager.default.fileExists(atPath: fileURL.path), // Ensure file exists
                                       let imageData = try? Data(contentsOf: fileURL), // Load Image Data
                                       let uiImage = UIImage(data: imageData) { // Convert to UIImage
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(Color.white, lineWidth: 2)
                                            )
                                    } else {
                                        Image("defaultProfileImage")  // Default system placeholder
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                                    }
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.editPlan = true
                        } label: {
                            Label("", systemImage: "ellipsis.circle")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.addExercise = true
                        } label: {
                            Label("", systemImage: "plus.circle")
                        }
                    }
                }
            }
        }
        .task {
            // Call sortData asynchronously when the view appears
            config.dayInSplit = viewModel.updateDayInSplit()
            config.lastUpdateDate = Date()
            await refreshMuscleGroups()
            navigationTitle = viewModel.day.name

        }
        .sheet(isPresented: $viewModel.editPlan, onDismiss: {
            Task {
                await refreshMuscleGroups()
            }
        }) {
            SplitView(viewModel: viewModel)
        }
        .sheet(isPresented: $showProfileView, onDismiss: {
            Task {
                await refreshMuscleGroups()
            }
        }) {
            SettingsView()
        }
        .sheet(isPresented: $viewModel.addExercise, onDismiss: {
            Task {
                await refreshMuscleGroups()
            }
        } ,content: {
                CreateExerciseView(viewModel: viewModel, day: viewModel.day)
                    .navigationTitle("Create Exercise")
                    .presentationDetents([.fraction(0.5)])
                
            })
        }
    
    func refreshMuscleGroups() async {
        muscleGroups.removeAll() // Clear array to trigger UI update
        muscleGroups = await viewModel.sortData(dayOfSplit: config.dayInSplit) // Reassign updated data
    }
    
    func loadImageFromDocuments(filename: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
}


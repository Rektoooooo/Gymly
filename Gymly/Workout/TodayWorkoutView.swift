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
    @State private var profileImage: UIImage?
    @State private var navigationTitle: String = ""
    @State var muscleGroups:[MuscleGroup] = []
    
    @State var selectedDay: Day = Day(name: "", dayOfSplit: 0, exercises: [], date: "")
    @State var allSplitDays: [Day] = []
    
    var body: some View {
        NavigationView{
            VStack {
                if !selectedDay.name.isEmpty {
                    VStack {
                        Menu {
                            ForEach(allSplitDays.sorted(by: { $0.dayOfSplit < $1.dayOfSplit }), id: \.self) { day in
                                Button(action: {
                                    selectedDay = day
                                    viewModel.day = selectedDay
                                    config.dayInSplit = day.dayOfSplit
                                    Task {
                                        await refreshView()
                                    }
                                }) {
                                    HStack {
                                        Text("\(day.dayOfSplit) - \(day.name)")
                                        if day == selectedDay {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(selectedDay.name)")
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(.leading)
                                Text(Image(systemName: "chevron.down"))
                                    .font(.title2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 16)
                            .foregroundStyle(Color.primary)
                        }
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
                                .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                } else {
                    VStack {
                        Text("Create your split with the \(Image(systemName: "line.2.horizontal.decrease.circle")) icon in the top right corner")
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showProfileView = true
                    }) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Image("defaultProfileImage")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.6), radius: 15, x: 0, y: 0)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.editPlan = true
                    } label: {
                        Label("", systemImage: "line.2.horizontal.decrease.circle")
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
            .id(UUID())
            .onChange(of: viewModel.exerciseAddedTrigger) {
                Task {
                    await refreshMuscleGroups()
                }
            }
        }
        .task {
            await refreshView()
        }
        .sheet(isPresented: $viewModel.editPlan, onDismiss: {
            Task {
                await refreshView()
                navigationTitle = viewModel.day.name
            }
        }) {
            SplitsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showProfileView, onDismiss: {
            if let imagePath = config.userProfileImageURL {
                profileImage = viewModel.loadImage(from: imagePath)
            }
            Task {
                await refreshMuscleGroups()
            }
        }) {
            SettingsView()
        }
        .sheet(isPresented: $viewModel.addExercise, onDismiss: {
            Task {
                await refreshView()
            }
            viewModel.name = ""
            viewModel.sets = ""
            viewModel.reps = ""
        } ,content: {
            CreateExerciseView(viewModel: viewModel, day: viewModel.day)
                .navigationTitle("Create Exercise")
                .presentationDetents([.fraction(0.5)])
            
        })
    }

    
    @MainActor
    func refreshMuscleGroups() async {
        let newMuscleGroups = await viewModel.sortData(dayOfSplit: config.dayInSplit)

        await MainActor.run {
            withAnimation() {  // ✅ Ensures smooth updates
                for newGroup in newMuscleGroups {
                    if let index = muscleGroups.firstIndex(where: { $0.id == newGroup.id }) {
                        // ✅ Instead of replacing the entire struct, update `exercises` separately
                        muscleGroups[index].exercises.append(contentsOf: newGroup.exercises.filter { newExercise in
                            !muscleGroups[index].exercises.contains(where: { $0.id == newExercise.id })
                        })
                    } else {
                        muscleGroups.append(newGroup)  // ✅ New muscle groups still animate properly
                    }
                }
            }

            // ✅ Remove muscle groups that no longer exist
            muscleGroups.removeAll { oldGroup in
                !newMuscleGroups.contains(where: { $0.id == oldGroup.id })
            }
        }
    }
    
    @MainActor
    func refreshView() async {
        allSplitDays = viewModel.getActiveSplitDays()
        config.dayInSplit = viewModel.updateDayInSplit()
        config.lastUpdateDate = Date()  // Track last update time
        let updatedDay = await viewModel.fetchDay(dayOfSplit: config.dayInSplit)
        await MainActor.run {
            viewModel.day = updatedDay
            selectedDay = updatedDay 
        }
        if let imagePath = config.userProfileImageURL {
            profileImage = viewModel.loadImage(from: imagePath)
        }
        await refreshMuscleGroups()
    }
}


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
    @State private var showWhatsNew = false
    
    var body: some View {
        NavigationView{
            VStack {
                if !selectedDay.name.isEmpty {
                    VStack {
                        /// Display the navigation title with menu day selection
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
                        /// Display exercises in a day
                        List {
                            ForEach(muscleGroups) { group in
                                if !group.exercises.isEmpty {
                                    Section(header: Text(group.name)) {
                                        ForEach(group.exercises, id: \.id) { exercise in
                                            NavigationLink(destination: ExerciseDetailView(viewModel: viewModel, exercise: exercise)) {
                                                HStack {
                                                    
                                                    Text("\(exercise.exerciseOrder)")
                                                        .foregroundStyle(Color.white.opacity(0.4))
                                                    Text(exercise.name)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            /// Save workout to the calendar button
                            Section("") {
                                Button("Workout done") {
                                    viewModel.updateMuscleGroupDataValues(from: selectedDay.exercises)
                                    Task {
                                        await viewModel.insertWorkout()
                                    }
                                }
                                .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                } else {
                    /// If no split is created show help message
                    VStack {
                        Text("Create your split with the \(Image(systemName: "line.2.horizontal.decrease.circle")) icon in the top right corner")
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .toolbar {
                /// Display user profile image as a button for getting to setting view
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showProfileView = true
                    }) {
                        ProfileImageCell(profileImage: profileImage, frameSize: 43)
                    }
                }
                /// Button for showing splits view
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.editPlan = true
                    } label: {
                        Label("", systemImage: "line.2.horizontal.decrease.circle")
                    }
                }
                /// Button for adding exercise
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addExercise = true
                    } label: {
                        Label("", systemImage: "plus.circle")
                    }
                }
            }
            /// On change of adding exercise refresh the exercises
            .onChange(of: viewModel.exerciseAddedTrigger) {
                Task {
                    await refreshMuscleGroups()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.importSplit)) { notification in
                Task {
                    await refreshView()
                }
            }
        }
        /// Refresh on every appear
        .task {
            await refreshView()
            if WhatsNewManager.shouldShowWhatsNew {
                showWhatsNew = true
            }
        }
        /// Sheet for showing splits view
        .sheet(isPresented: $viewModel.editPlan, onDismiss: {
            Task {
                await refreshView()
                navigationTitle = viewModel.day.name
            }
        }) {
            SplitsView(viewModel: viewModel)
        }
        /// Sheet for showing setting and profile view
        .sheet(isPresented: $showProfileView, onDismiss: {
            if let imagePath = config.userProfileImageURL {
                profileImage = viewModel.loadImage(from: imagePath)
            }
            Task {
                await refreshMuscleGroups()
            }
        }) {
            SettingsView(viewModel: viewModel)
        }
        /// Sheet for adding exercises
        .sheet(isPresented: $viewModel.addExercise, onDismiss: {
            Task {
                await refreshView()
            }
            viewModel.name = ""
            viewModel.sets = ""
            viewModel.reps = ""
        } ,content: {
            CreateExerciseView(viewModel: viewModel, day: selectedDay)
                .navigationTitle("Create Exercise")
                .presentationDetents([.fraction(0.5)])
            
        })
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewView(isPresented: $showWhatsNew)
        }
    }
    
    // TODO: When adding exercise, adding new exercise into new muscle group works fine with animation and everything, but when adding second exercise to already existing muscle group there is no animation Sadge
    
    /// Func for refreshing exercises so UI updates correctly
    @MainActor
    func refreshMuscleGroups() async {
        let newMuscleGroups = await viewModel.sortData(dayOfSplit: config.dayInSplit)
        await MainActor.run {
            withAnimation {
                for newGroup in newMuscleGroups {
                    if let index = muscleGroups.firstIndex(where: { $0.id == newGroup.id }) {
                        muscleGroups[index] = MuscleGroup(id: newGroup.id, name: newGroup.name, exercises: newGroup.exercises)
                    } else {
                        muscleGroups.append(newGroup)
                    }
                }
                muscleGroups.removeAll { oldGroup in
                    !newMuscleGroups.contains(where: { $0.id == oldGroup.id })
                }
            }
        }
    }
    
    /// Func for keeping up view up to date
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


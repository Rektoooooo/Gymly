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
                Menu {
                    let uniqueDays = removeDuplicateDays(from: allSplitDays)
                    ForEach(uniqueDays.sorted(by: { $0.dayOfSplit < $1.dayOfSplit }), id: \.self) { day in
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
                .id(UUID())
                .onChange(of: viewModel.addExercise) {
                    Task {
                        await refreshMuscleGroups()
                    }
                }
            }
        }
        .task {
           await refreshView()
        }
        .sheet(isPresented: $viewModel.editPlan, onDismiss: {
            Task {
                await refreshMuscleGroups()
                navigationTitle = viewModel.day.name
            }
        }) {
            ShowSplitView(viewModel: viewModel)
        }
        .sheet(isPresented: $showProfileView, onDismiss: {
            if let imagePath = config.userProfileImageURL {
                profileImage = loadImage(from: imagePath)
            }
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
            viewModel.name = ""
            viewModel.sets = ""
            viewModel.reps = ""
        } ,content: {
                CreateExerciseView(viewModel: viewModel, day: viewModel.day)
                    .navigationTitle("Create Exercise")
                    .presentationDetents([.fraction(0.5)])
                
            })
        }
    
    func refreshMuscleGroups() async {
        let newMuscleGroups = await viewModel.sortData(dayOfSplit: config.dayInSplit)

        withAnimation {
            for newGroup in newMuscleGroups {
                if let index = muscleGroups.firstIndex(where: { $0.id == newGroup.id }) {
                    muscleGroups[index] = newGroup
                } else {
                    muscleGroups.append(newGroup)
                }
            }
            
            muscleGroups.removeAll { oldGroup in
                !newMuscleGroups.contains(where: { $0.id == oldGroup.id })
            }
        }
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
    
    func loadImage(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let imageData = try? Data(contentsOf: fileURL),
              let uiImage = UIImage(data: imageData) else {
            return nil
        }
        return uiImage
    }
    
    /// **Helper function to remove duplicate `dayOfSplit` values**
    private func removeDuplicateDays(from days: [Day]) -> [Day] {
        var seenSplits = Set<Int>()
        return days.filter { seenSplits.insert($0.dayOfSplit).inserted } // Keep only the first occurrence
    }
    
    func refreshView() async {
        allSplitDays = await viewModel.fetchAllDays()
        config.dayInSplit = viewModel.updateDayInSplit()
        config.lastUpdateDate = Date()
        await refreshMuscleGroups()
        selectedDay = viewModel.day
        if let imagePath = config.userProfileImageURL {
            profileImage = loadImage(from: imagePath)
        }
    }
    
}


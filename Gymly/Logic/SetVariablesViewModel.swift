//
//  setVariablesViewModel.swift
//  Gymly
//
//  Created by Sebastián Kučera on 23.10.2024.
//

import Foundation

final class SetVariablesViewModel: ObservableObject {
    @Published var weekDays:[String] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Sutarday","Sunday"]
    @Published var muscleGroupNames:[String] = ["Chest","Back","Biceps","Triceps","Shoulders","Legs","Abs"]
}

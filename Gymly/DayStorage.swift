//
//  DayStorage.swift
//  Gymly
//
//  Created by Sebastián Kučera on 29.08.2024.
//

import Foundation
import SwiftData

@Model
class DayStorage {
    var id: UUID
    var day: Day
    @Attribute(.unique) var date: String
    
    init(id: UUID, day: Day, date: String) {
        self.id = id
        self.day = day
        self.date = date
    }
}

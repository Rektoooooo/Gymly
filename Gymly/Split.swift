//
//  Split.swift
//  Gymly
//
//  Created by Sebastián Kučera on 27.02.2025.
//

import Foundation
import SwiftData

@Model
class Split {
    @Attribute(.unique) var id: UUID
    var name: String
    var days: [Day] 
    var isActive: Bool
    var startDate: Date

    init(id: UUID = UUID(), name: String, days: [Day] = [], isActive: Bool = false, startDate: Date) {
        self.id = id
        self.name = name
        self.days = days
        self.isActive = isActive
        self.startDate = startDate
    }
}

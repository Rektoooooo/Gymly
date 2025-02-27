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
    var days: [Day] // Each split contains multiple days
    var isActive: Bool // Only ONE split should be active
    var startDate: Date // When the split begins

    init(id: UUID = UUID(), name: String, days: [Day] = [], isActive: Bool = false, startDate: Date) {
        self.id = id
        self.name = name
        self.days = days
        self.isActive = isActive
        self.startDate = startDate
    }
}

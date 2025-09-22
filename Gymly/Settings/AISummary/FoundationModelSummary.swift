//
//  FoundationModelSummary.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.09.2025.
//

import Playgrounds
import FoundationModels

#Playground {
    let session = LanguageModelSession()
    let response = try await session.respond(to: "Summarise todays workout")
}

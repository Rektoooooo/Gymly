//
//  CalendarView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 30.08.2024.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "calendar")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Calendar")
            }
            .navigationTitle("Calendar")
            .padding()
        }
    }
}

#Preview {
    CalendarView()
}

//
//  AccountView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 13.05.2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @EnvironmentObject var config: Config

    @State var selectedUnit:String = ""
    let units: [String] = ["Kg","Lbs"]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("App settings") {
                        HStack {
                            Text("Weight unit")
                            Picker("Weight unit", selection: $config.weightUnit) {
                                ForEach(units, id: \.self) { unit in
                                    Text("\(unit)")
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: selectedUnit) {
                                debugPrint("Selected unit : \(selectedUnit)")
                                config.weightUnit = selectedUnit
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .padding()
        }
    }
}

#Preview {
    SettingsView()
}

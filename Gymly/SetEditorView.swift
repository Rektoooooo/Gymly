//
//  SetEditorView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 20.09.2024.
//

import SwiftUI

struct SetEditorView: View {
    
    @Binding var weight: Int
    @Binding var reps: Int
    @Binding var failure:Bool
    @Binding var unit: String
    @Binding var setNumber: Int
    @State var exercise:Exercise

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Weight (\(unit))") {
                    HStack {
                        Button {
                            weight -= 1
                        } label: {
                            HStack {
                                Image(systemName: "minus")
                                Label("", systemImage: "1.square")
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            weight -= 5
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.leading , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        Text("\(weight) \(unit)")
                            .font(.title2)
                        Spacer()
                        Button {
                            weight += 5
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.trailing , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            weight += 1
                        } label: {
                            HStack {
                                Label("", systemImage: "1.square")
                                Image(systemName: "plus")
                                    .padding(.leading , -20)
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Section("Repetisitions") {
                    HStack {
                        Button {
                            reps -= 1
                        } label: {
                            HStack {
                                Image(systemName: "minus")
                                Label("", systemImage: "1.square")
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            reps -= 5
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.leading , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        Text("\(reps)")
                            .font(.title2)
                        Spacer()
                        Button {
                            reps += 5
                        } label: {
                            Label("", systemImage: "5.square")
                                .padding(.trailing , -15)
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                        Button {
                            reps += 1
                        } label: {
                            HStack {
                                Label("", systemImage: "1.square")
                                Image(systemName: "plus")
                                    .padding(.leading , -20)
                            }
                        }
                        .font(.title2)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Section("Failuer reached") {
                    Toggle("Failuer", isOn: $failure)
                        .toggleStyle(CheckToggleStyle())
                }
            }
            .offset(y : -20)
            .navigationTitle("Record set")
            .navigationBarTitleDisplayMode(.inline)
        }
        Button("Save") {
            exercise.sets[setNumber].weight = weight
            exercise.sets[setNumber].reps = reps
            exercise.sets[setNumber].failure = failure
            do {
                try context.save()
            } catch {
                debugPrint(error)
            }
            dismiss()
        }
        .padding(20)
    }
}

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(.plain)
    }
}



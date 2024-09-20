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
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("weight")
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.gray)
                        .kerning(2)
                        .offset(y: 25)
                        .padding()
                    Spacer()
                }
                HStack {
                    Button {
                        weight -= 1
                    } label: {
                        Image(systemName: "minus")
                        Label("", systemImage: "1.square")
                    }.font(.title2)
                    Button {
                        weight -= 5
                    } label: {
                        Label("", systemImage: "5.square")
                    }.font(.title2)
                    Spacer()
                    Text("\(weight) \(unit)")
                        .font(.title2)
                    Spacer()
                    Button {
                        weight += 5
                    } label: {
                        Label("", systemImage: "5.square")
                    }.font(.title2)
                    Button {
                        weight += 1
                    } label: {
                        Label("", systemImage: "1.square")
                        Image(systemName: "plus")
                    }.font(.title2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.black.opacity(1))
                .cornerRadius(10)
                .padding()
            }
            .offset(y: -30)
            
            VStack {
                HStack {
                    Text("repeticions")
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.gray)
                        .kerning(1)
                        .offset(y: 25)
                        .padding()
                    Spacer()
                }
                HStack {
                    Button {
                        reps -= 1
                    } label: {
                        Image(systemName: "minus")
                        Label("", systemImage: "1.square")
                    }.font(.title2)
                    Button {
                        reps -= 5
                    } label: {
                        Label("", systemImage: "5.square")
                    }.font(.title2)
                    Spacer()
                    Text("\(reps)")
                        .font(.title2)
                    Spacer()
                    Button {
                        reps += 5
                    } label: {
                        Label("", systemImage: "5.square")
                    }.font(.title2)
                    Button {
                        reps += 1
                    } label: {
                        Label("", systemImage: "1.square")
                        Image(systemName: "plus")
                    }.font(.title2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.black.opacity(1))
                .cornerRadius(10)
                .padding()
            }
            .offset(y: -80)
            
            Text("\(failure)")
            Spacer()
        }
    }
}

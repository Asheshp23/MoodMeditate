//
//  MoodInputView.swift
//  MoodMeditate
//
//  Created by Ashesh Patel on 2025-01-01.
//
import SwiftUI

struct MoodInputView: View {
    @Binding var showingMoodView: Bool
    @State private var moodRating = 3
    @State private var notes = ""
    @State private var savingMood = false

    var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling today?")
                .font(.headline)

            Picker("Mood", selection: $moodRating) {
                ForEach(1...5, id: \ .self) { rating in
                    Text("\(rating)").tag(rating)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            TextField("Add notes (optional)", text: $notes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: saveMood) {
                if savingMood {
                    ProgressView()
                } else {
                    Text("Save Mood")
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }

    func saveMood() {
        savingMood = true
      HealthKitService.shared.saveMomentaryEmotion(emotion: "1", notes: notes, completion: { success, _  in
        savingMood = false
        showingMoodView = false
      })
    }
                                                   
}

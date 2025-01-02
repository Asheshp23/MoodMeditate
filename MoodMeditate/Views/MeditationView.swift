//
//  MeditationView.swift
//  MoodMeditate
//
//  Created by Ashesh Patel on 2025-01-01.
//
import SwiftUI

struct MeditationView: View {
  @State private var meditationStarted = false
  @State private var meditationEndTime: Date? = nil
  
  var body: some View {
    VStack(spacing: 20) {
      if meditationStarted {
        Text("Meditating... Relax and breathe deeply.")
          .font(.title2)
          .multilineTextAlignment(.center)
        
        Button("End Meditation") {
          endMeditation()
        }
        .buttonStyle(.borderedProminent)
        .padding()
        
        if let endTime = meditationEndTime {
          Text("Ended at: \(endTime, style: .time)")
            .font(.footnote)
        }
      } else {
        Button("Start Meditation") {
          startMeditation()
        }
        .buttonStyle(.borderedProminent)
        .padding()
      }
    }
    .padding()
  }
  
  func startMeditation() {
    meditationStarted = true
    meditationEndTime = nil
  }
  
  func endMeditation() {
    meditationStarted = false
    meditationEndTime = Date()
  }
}

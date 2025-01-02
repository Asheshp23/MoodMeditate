//
//  ContentView.swift
//  MoodMeditate
//
//  Created by Ashesh Patel on 2024-12-18.
//
import SwiftUI
import HealthKit

struct ContentView: View {
  @State private var isAuthorized = false
  @State private var showingMoodView = true
  
  var body: some View {
    Group {
      if showingMoodView {
        StateOfMindView(healthStore: HKHealthStore())
      } else {
        MeditationView()
      }
    }
    .onAppear {
      requestHealthKitAuthorization()
    }
  }
  
  func requestHealthKitAuthorization() {
    HealthKitService.shared.requestAuthorization { success, error in
      DispatchQueue.main.async {
        isAuthorized = success
        if !success {
       
                }
                }
                }
                }
                
                }
                #Preview {
            ContentView()
          }

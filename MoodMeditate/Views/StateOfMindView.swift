//
//  StateOfMindView.swift
//  MoodMeditate
//
//  Created by Ashesh Patel on 2025-01-01.
//
import SwiftUI
import HealthKit

@available(iOS 18.0, *)
struct StateOfMindView: View {
    @State private var selectedValence: ValenceClassification = .neutral
    @State private var selectedLabels: Set<HKStateOfMind.Label> = []
    @State private var selectedAssociations: Set<HKStateOfMind.Association> = []
    @State private var notes: String = ""
    
    var healthStore: HKHealthStore
    
  var body: some View {
    Form {
      Section(header: Text("Valence")) {
        Picker("Valence", selection: $selectedValence) {
          ForEach(ValenceClassification.allCases, id: \.self) { valence in
            Text("\(valence)")
          }
          .pickerStyle(WheelPickerStyle())
        }
        
        Section(header: Text("Labels")) {
          List(HKStateOfMind.Label.allCases, id: \.self) { label in
            MultipleSelectionRow(label: label, isSelected: selectedLabels.contains(label)) {
              if selectedLabels.contains(label) {
                selectedLabels.remove(label)
              } else {
                selectedLabels.insert(label)
              }
            }
          }
        }
        
        Section(header: Text("Associations")) {
          List(HKStateOfMind.Association.allCases, id: \.self) { association in
            MultipleSelectionRow(label: association, isSelected: selectedAssociations.contains(association)) {
              if selectedAssociations.contains(association) {
                selectedAssociations.remove(association)
              } else {
                selectedAssociations.insert(association)
              }
            }
          }
        }
        
        Section(header: Text("Notes")) {
          TextField("Enter notes", text: $notes)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        
        Button("Save State of Mind") {
          Task {
            await createSample()
          }
        }
        .disabled(selectedLabels.isEmpty || selectedAssociations.isEmpty)
      }
      .navigationBarTitle("State of Mind")
      
    }
  }
    
    private func createSample() async {
      let now = Date()
      let mappedValence = mapValenceToRange(selectedValence)
      healthStore.requestAuthorization(toShare: [.stateOfMindType()], read: [.stateOfMindType()]) { success, error in
        if let error = error {
          print("Error requesting authorization: \(error.localizedDescription)")
        } else if success {
          print("HealthKit authorization granted")
        } else {
          print("HealthKit authorization denied")
        }
      }
      
        let sample = HKStateOfMind(
            date: now,
            kind: .momentaryEmotion,
            valence: mappedValence,
            labels: Array(selectedLabels),
            associations: Array(selectedAssociations),
            metadata: ["notes": notes]
        )
        
        debugPrint("First sample: \(sample)")
        await save(sample: sample, healthStore: healthStore)
    }
    
    private func save(sample: HKSample, healthStore: HKHealthStore) async {
        do {
            try await healthStore.save(sample)
            print("State of Mind sample saved successfully")
        } catch {
            print("Error saving State of Mind sample: \(error.localizedDescription)")
        }
    }
  
  private func mapValenceToRange(_ valence: ValenceClassification) -> Double {
    switch valence {
    case .veryUnpleasant:
      return -1.0
    case .unpleasant:
      return -0.75
    case .slightlyUnpleasant:
      return -0.5
    case .neutral:
      return 0.0
    case .slightlyPleasant:
      return 0.25
    case .pleasant:
      return 0.5
    case .veryPleasant:
      return 1.0
    }
  }
}

@available(iOS 18.0, *)
struct MultipleSelectionRow: View {
    var label: CustomStringConvertible
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(label.description)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
            } else {
                Image(systemName: "circle")
            }
        }
        .onTapGesture {
            action()
        }
    }
}

@available(iOS 18.0, *)
struct StateOfMindView_Previews: PreviewProvider {
    static var previews: some View {
        StateOfMindView(healthStore: HKHealthStore())
    }
}

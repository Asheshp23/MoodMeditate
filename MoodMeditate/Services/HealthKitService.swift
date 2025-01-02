//
//  HealthKitService.swift
//  MoodMeditate
//
//  Created by Ashesh Patel on 2025-01-01.
//
import HealthKit

class HealthKitService {
  private let healthStore = HKHealthStore()
  
  // Singleton instance (optional)
  static let shared = HealthKitService()
  
  private init() {}
  
  // MARK: - Request Authorization
  func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
    guard let moodType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
      completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mindful Session type unavailable"]))
      return
    }
    
    let typesToShare: Set = [moodType]
    let typesToRead: Set = [moodType]
    
    healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
      completion(success, error)
    }
  }
  
  
  func saveMomentaryEmotion(emotion: String, notes: String?, completion: @escaping (Bool, Error?) -> Void) {
    // Ensure the mood type is available
    guard let moodType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
      let error = NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mindful Session type unavailable"])
      completion(false, error)
      return
    }
    
    let startDate = Date()
    let endDate = startDate.addingTimeInterval(300)
    
    // Create the mood sample with metadata for the emotion
    let moodSample = HKCategorySample(
      type: moodType,
      value: HKCategoryValue.notApplicable.rawValue, // Momentary emotion doesn't use predefined values
      start: startDate,
      end: endDate,
      metadata: [
        "Emotion": emotion, // Store emotion as a custom string
        "Notes": notes ?? ""
      ]
    )
    
    // Save to HealthKit
    healthStore.save(moodSample) { success, error in
      completion(success, error)
    }
  }


  // MARK: - Fetch Mood Data from HealthKit
  func fetchMoods(completion: @escaping ([HKCategorySample], Error?) -> Void) {
    guard let moodType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
      completion([], NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mindful Session type unavailable"]))
      return
    }
    
    let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    let query = HKSampleQuery(
      sampleType: moodType,
      predicate: predicate,
      limit: HKObjectQueryNoLimit,
      sortDescriptors: [sortDescriptor]
    ) { _, samples, error in
      let moodSamples = samples as? [HKCategorySample] ?? []
      completion(moodSamples, error)
    }
    
    healthStore.execute(query)
  }
  
  func createSample() async {
    let now = Date()
    
    let sample = HKStateOfMind(
      date: now,
      kind: .momentaryEmotion,
      valence: 0.7,
      labels: [.happy, .excited],
      associations: [.work, .friends],
      metadata: ["notes": "Just finished a great project with my team!"] as [String : Any]
    )
    
    debugPrint("First sample: \(sample)")
    await save(sample: sample, healthStore: healthStore)
  }
  
  func save(sample: HKSample, healthStore: HKHealthStore) async {
    do {
      try await healthStore.save(sample)
      print("State of Mind sample saved successfully")
    } catch {
      print("Error saving State of Mind sample: \(error.localizedDescription)")
    }
  }
  
}


@available(iOS 18.0, *)
public enum ValenceClassification: Int, @unchecked Sendable, CaseIterable {
  case veryUnpleasant = 1
  case unpleasant = 2
  case slightlyUnpleasant = 3
  case neutral = 4
  case slightlyPleasant = 5
  case pleasant = 6
  case veryPleasant = 7
  
  // Make sure to conform to `CaseIterable` to provide allCases
  public static var allCases: [ValenceClassification] {
    return [.veryUnpleasant, .unpleasant, .slightlyUnpleasant, .neutral, .slightlyPleasant, .pleasant, .veryPleasant]
  }
}


@available(iOS 18.0, *)
public enum Kind : Int, @unchecked Sendable {
  case momentaryEmotion = 1
  case dailyMood = 2
}

extension HKStateOfMind.ValenceClassification: @retroactive CustomStringConvertible {
  public var description: String {
    switch self {
    case .veryUnpleasant: "Very Unpleasant"
    case .unpleasant: "Unpleasant"
    case .slightlyUnpleasant: "Slightly Unpleasant"
    case .neutral: "Neutral"
    case .slightlyPleasant: "Slightly Pleasant"
    case .pleasant: "Pleasant"
    case .veryPleasant: "Very Pleasant"
    @unknown default: "Neutral"
    }
  }
}

@available(iOS 18.0, *)
public enum Label: Int, @unchecked Sendable {
  case amazed = 1
  case amused = 2
  case angry = 3
  case anxious = 4
  case ashamed = 5
  case brave = 6
  case calm = 7
  case content = 8
  case disappointed = 9
  case discouraged = 10
  case disgusted = 11
  case embarrassed = 12
  case excited = 13
  case frustrated = 14
  case grateful = 15
  case guilty = 16
  case happy = 17
  case hopeless = 18
  case irritated = 19
  case jealous = 20
  case joyful = 21
  case lonely = 22
  case passionate = 23
  case peaceful = 24
  case proud = 25
  case relieved = 26
  case sad = 27
  case scared = 28
  case stressed = 29
  case surprised = 30
  case worried = 31
  case annoyed = 32
  case confident = 33
  case drained = 34
  case hopeful = 35
  case indifferent = 36
  case overwhelmed = 37
  case satisfied = 38
}

extension HKStateOfMind.Label: @retroactive CaseIterable, @retroactive CustomStringConvertible {
  public var description: String {
    switch self {
    case .amazed: "Amazed"
    case .amused: "Amused"
    case .angry: "Angry"
    case .anxious: "Anxious"
    case .ashamed: "Ashamed"
    case .brave: "Brave"
    case .calm: "Calm"
    case .content: "Content"
    case .disappointed: "Disappointed"
    case .discouraged: "Discouraged"
    case .disgusted: "Disgusted"
    case .embarrassed: "Embarrassed"
    case .excited: "Excited"
    case .frustrated: "Frustrated"
    case .grateful: "Grateful"
    case .guilty: "Guilty"
    case .happy: "Happy"
    case .hopeless: "Hopeless"
    case .irritated: "Irritated"
    case .jealous: "Jealous"
    case .joyful: "Joyful"
    case .lonely: "Lonely"
    case .passionate: "Passionate"
    case .peaceful: "Peaceful"
    case .proud: "Proud"
    case .relieved: "Relieved"
    case .sad: "Sad"
    case .scared: "Scared"
    case .stressed: "Stressed"
    case .surprised: "Surprised"
    case .worried: "Worried"
    case .annoyed: "Annoyed"
    case .confident: "Confident"
    case .drained: "Drained"
    case .hopeful: "Hopeful"
    case .indifferent: "Indifferent"
    case .overwhelmed: "Overwhelmed"
    case .satisfied: "Satisfied"
    @unknown default: "Unknown"
    }
  }
  
  static func fromIntegerValue(_ value: Int) -> HKStateOfMind.Label? {
    HKStateOfMind.Label(rawValue: value)
  }
  
  public static var allCases: [HKStateOfMind.Label] {
    [
      .amazed, .amused, .angry, .anxious, .ashamed,
      .brave, .calm, .content, .disappointed, .discouraged,
      .disgusted, .embarrassed, .excited, .frustrated, .grateful,
      .guilty, .happy, .hopeless, .irritated, .jealous,
      .joyful, .lonely, .passionate, .peaceful, .proud,
      .relieved, .sad, .scared, .stressed, .surprised,
      .worried, .annoyed, .confident, .drained, .hopeful,
      .indifferent, .overwhelmed, .satisfied
    ]
  }
}

extension HKStateOfMind.Association: @retroactive CaseIterable, @retroactive CustomStringConvertible {
  public var description: String {
    switch self {
    case .community: "Community"
    case .currentEvents: "Current Events"
    case .dating: "Dating"
    case .education: "Education"
    case .family: "Family"
    case .fitness: "Fitness"
    case .friends: "Friends"
    case .health: "Health"
    case .hobbies: "Hobbies"
    case .identity: "Identity"
    case .money: "Money"
    case .partner: "Partner"
    case .selfCare: "Self Care"
    case .spirituality: "Spirituality"
    case .tasks: "Tasks"
    case .travel: "Travel"
    case .work: "Work"
    case .weather: "Weather"
    @unknown default: "Unknown"
    }
  }
  
  public static var allCases: [HKStateOfMind.Association] {
    [
      .community, .currentEvents, .dating, .education, .family,
      .fitness, .friends, .health, .hobbies, .identity,
      .money, .partner, .selfCare, .spirituality, .tasks,
      .travel, .work, .weather
    ]
  }
}

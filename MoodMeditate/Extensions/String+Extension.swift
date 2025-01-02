//
//  String+Extension.swift
//  MoodMeditate
//
//  Created by Ashesh Patel on 2024-12-18.
//
import Foundation

internal extension String {
  func droppingLeadingPoundSign() -> String {
    if starts(with: "#") {
      return String(dropFirst())
    }
    return self
  }
}

//
//  AccountSectionViewModel.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 29/03/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

typealias JsonDictionary = [String: JsonPrimitive]

protocol JsonPrimitive {}

extension String: JsonPrimitive {}
extension Int: JsonPrimitive {}
extension Float: JsonPrimitive {}
extension Double: JsonPrimitive {}
extension Bool: JsonPrimitive {}
extension Array: JsonPrimitive where Element == JsonPrimitive {}
extension Dictionary: JsonPrimitive where Key == String, Value == JsonPrimitive {}

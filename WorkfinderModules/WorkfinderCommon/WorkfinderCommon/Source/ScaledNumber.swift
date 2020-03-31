//
//  ScaledNumber.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 25/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import Foundation

public struct ScaledNumber {
    
    public enum Scale : Double {
        case base = 1
        case thousand = 1_000
        case million = 1_000_000
        case billion = 1_000_000_000
        case trillion = 1_000_000_000_000
    }
    
    let symbol: String
    let scale: Scale
    let amount: Double
    
    public func formattedString() -> String {
        if scale.rawValue >= Scale.thousand.rawValue {
            return String(format: "%.1f%", amount / scale.rawValue) + symbol
        }
        return String(format: "%.f", amount)
    }
    
    public static func formattedString(for amount: Double) -> String {
        let scaledNumber = ScaledNumber(amount: amount)
        return scaledNumber.formattedString()
    }
    
    public init(amount:Double) {
        self.amount = amount
        if ScaledNumber.inScale(amount: amount, scale: Scale.trillion) {
            symbol = "t"
            scale = Scale.trillion
            return
        }
        if ScaledNumber.inScale(amount: amount, scale: Scale.billion) {
            symbol = "b"
            scale = Scale.billion
            return
        }
        if ScaledNumber.inScale(amount: amount, scale: Scale.million) {
            symbol = "m"
            scale = Scale.million
            return
        }
        if ScaledNumber.inScale(amount: amount, scale: Scale.thousand) {
            symbol = "k"
            scale = Scale.thousand
            return
        }
        symbol = ""
        scale = Scale.base
    }
    
    static func discriminator(amount: Double, scale: Scale) -> Double {
        return round((10.0*amount/Double(scale.rawValue)))
    }
    
    static func inScale(amount: Double, scale: Scale) -> Bool {
        if amount < 1000 { return false }
        let d = discriminator(amount: amount, scale: scale)
        return d > 1.0
    }
}

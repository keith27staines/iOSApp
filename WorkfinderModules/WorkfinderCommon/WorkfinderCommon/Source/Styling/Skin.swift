//
//  Skin.swift
//  Skins
//
//  Created by Keith Dev on 10/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public typealias Skins = [String : Skin]

public struct Skin : Codable {
    public static var jsonDocumentNameWithExtension = "skins.json"
    public static var plistDocumentName = "skins"
    public var name: String
    public var workfinderLogoName: String
    public var partnerLogoName: String? = nil
    public var primaryButtonSkin: ButtonSkin
    public var secondaryButtonSkin: ButtonSkin
    public var ghostButtonSkin: ButtonSkin
    public var navigationBarSkin: NavigationBarSkin
    public var tabBarSkin: TabBarSkin
}

public extension Skin {
    public static func skinsJsonData(skins: Skins) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(skins)
    }
    
    public static func skinsPlistData(skins: Skins) throws -> Data {
        let encoder = PropertyListEncoder()
        return try encoder.encode(skins)
    }
    
    public static func writeSkinsToDocumentDirectory(skins: Skins) {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let url = documentDirectory.appendingPathComponent(jsonDocumentNameWithExtension)
            let data = try skinsJsonData(skins: skins)
            try data.write(to: url, options: .atomic)
        } catch {
            print(error)
        }
    }
}

public extension Skin {
    public static func loadSkins() -> Skins {
        let skins = FactorySkins.skins
        Skin.writeSkinsToDocumentDirectory(skins: skins)
        return FactorySkins.skins
        
//        var skins = Skin.readSkinsFromPlist()
//            if let skins = skins {
//                Skin.writeSkinsToDocumentDirectory(skins: skins)
//            }
//        }
//        if skins == nil {
//            skins = FactorySkins.skins
//            if let skins = skins {
//                Skin.writeSkinsToDocumentDirectory(skins: skins)
//            }
//        }
//        return skins ?? [:]
    }
    
    public static func readSkinsFromPlist() -> Skins? {
        guard let url = Bundle.main.url(forResource: plistDocumentName, withExtension: "plist") else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = PropertyListDecoder()
        return try! decoder.decode(Skins.self, from: data)
    }
    
    public static func readSkinsFromDocumentDirectory() -> Skins? {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let url = documentDirectory.appendingPathComponent(jsonDocumentNameWithExtension)
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let skins = try decoder.decode(Skins.self, from: data)
            return skins
        } catch {
            print(error)
            return nil
        }
    }
}

public struct ButtonSkin : Codable {
    public var cornerRadius: CGFloat = 8
    public var backgroundColor: RGBA = RGBA(color: UIColor.blue)
    public var textColor: RGBA = RGBA(color: UIColor.white)
    public var borderColor: RGBA = RGBA(color: UIColor.clear)
    public var borderWidth: CGFloat = 2.0
}


public struct NavigationBarSkin : Codable {
    public static var whiteBarBlackItems: NavigationBarSkin {
         let barSkin = NavigationBarSkin(statusbarMode: .dark, barTintColor: RGBA.white, itemTintColor: RGBA.black, titleTintColor: RGBA.black, hasDropShadow: false)
        return barSkin
    }
    
    public enum StatusbarMode : String, Codable {
        case dark = "dark"
        case light = "light"
    }
    public var statusbarMode: StatusbarMode = StatusbarMode.dark
    public var barTintColor: RGBA = RGBA(color: UIColor.yellow)
    public var itemTintColor: RGBA = RGBA(color: UIColor.red)
    public var titleTintColor: RGBA = RGBA(color: UIColor.blue)
    public var hasDropShadow: Bool = true
}

public struct TabBarSkin : Codable {
    public var barTintColor: RGBA = RGBA(color: UIColor.white)
    public var itemTintColor: RGBA = RGBA(color: UIColor.lightGray)
    public var selectedItemTintColor: RGBA = RGBA.black
}



















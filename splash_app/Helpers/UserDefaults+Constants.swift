//
//  UserDefaults+Constants.swift
//  splash
//
//  Created by Gonzo Fialho on 12/03/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import Foundation

extension UserDefaults.Domain {
    static let splashApp = UserDefaults.Domain(name: "splash_app")
}

extension UserDefaults.Key {
    static let lastUsedTheme = UserDefaults.Key(domain: .splashApp, keyName: "current theme")
    static let alreadyShowedOnboard1 = UserDefaults.Key(domain: .splashApp, keyName: "already showed onboard 1")
    static let alreadyInstalledExamples1 = UserDefaults.Key(domain: .splashApp, keyName: "already installed examples 1")
}

extension UserDefaults {

    var alreadyInstalledExamples1: Bool {
        get {
            return UserDefaults.standard.bool(forKey: .alreadyInstalledExamples1)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .alreadyInstalledExamples1)
        }
    }

    var alreadyShowedOnboard1: Bool {
        get {
            return UserDefaults.standard.bool(forKey: .alreadyShowedOnboard1)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .alreadyShowedOnboard1)
        }
    }

    var lastUsedTheme: ThemeManager.Theme {
        get {
            guard let themeName = string(forKey: .lastUsedTheme),
                let theme = ThemeManager.Theme(rawValue: themeName) else {
                    return .light  // default theme
            }
            return theme
        }
        set {
            set(newValue.rawValue, forKey: .lastUsedTheme)
        }
    }
}

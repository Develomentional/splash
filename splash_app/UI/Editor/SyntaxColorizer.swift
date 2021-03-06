//
//  SyntaxColorizer.swift
//  splash
//
//  Created by Gonzo Fialho on 04/03/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import UIKit

class SyntaxColorizer {
    enum TokenKind {
        case regular
        case comment
        case keyword
        case functionCall
        case identifier
        case number
        case string
        case error

        var foregroundLightColor: UIColor {
            switch self {
            case .regular: return UIColor(hex: 0x000000)
            case .comment: return UIColor(hex: 0x536579)
            case .keyword: return UIColor(hex: 0x9B2393)
            case .functionCall: return UIColor(hex: 0x3900A0)
            case .identifier: return UIColor(hex: 0x000000)
            case .number: return UIColor(hex: 0x1C00CF)
            case .string: return UIColor(hex: 0xC41A16)
            case .error: return UIColor(hex: 0x000000)
            }
        }

        var foregroundDarkColor: UIColor {
            switch self {
            case .regular: return UIColor(hex: 0xffffff)
            case .comment: return UIColor(hex: 0x6C7986)
            case .keyword: return UIColor(hex: 0xFC5FA3)
            case .functionCall: return UIColor(hex: 0x75B492)
            case .identifier: return UIColor(hex: 0xffffff)
            case .number: return UIColor(hex: 0x9686F5)
            case .string: return UIColor(hex: 0xFC6A5D)
            case .error: return UIColor(hex: 0xffffff)
            }
        }

        func foregroundColor(`for` theme: ThemeManager.Theme) -> UIColor {
            switch theme {
            case .light: return foregroundLightColor
            case .dark: return foregroundDarkColor
            }
        }

        func backgroundColor(`for` theme: ThemeManager.Theme) -> UIColor? {
            if self == .error {
                return UIColor.red
            } else {
                return nil
            }
        }

        func attributes(`for` theme: ThemeManager.Theme) -> [NSAttributedString.Key: Any] {
            var attributes = [NSAttributedString.Key: Any]()
            attributes[.foregroundColor] = self.foregroundColor(for: theme)
            attributes[.backgroundColor] = self.backgroundColor(for: theme)

            switch self {
            case .comment: attributes[.font] = UIFont(name: "Menlo-Italic", size: UserDefaults.standard.fontSize)!
            case .keyword: attributes[.font] = UIFont(name: "Menlo-Bold", size: UserDefaults.standard.fontSize)!
            case .functionCall,
                 .identifier,
                 .number,
                 .regular,
                 .error,
                 .string: attributes[.font] = UIFont(name: "Menlo", size: UserDefaults.standard.fontSize)!
            }

            return attributes
        }
    }

    static let shared = SyntaxColorizer()

    lazy var knownFunctions: Set<String> = [
        "AskNumber",
        "AskText",
        "ShowResult",
        "Floor",
        "Ceil",
        "Round",
        "GetName",
        "GetType",
        "ViewContentGraph",
        "Wait",
        "Exit",
        "WaitToReturn",
        "GetBatteryLevel",
        "Date",
        "ExtractArchive",
        "GetCurrentLocation"
    ]

    lazy var patterns: [(String, TokenKind)] = [
        ("#.*?(?:$|\\n)", .comment),
        ("[a-zA-Z_][a-zA-Z_0-9]*(?=\\s*\\()", .functionCall),
        ("[a-zA-Z_][a-zA-Z_0-9]*", .identifier),
        ("[0-9]+(?:\\.[0-9]+)?", .number),
        ("\"(?:[^\"\\\\]|\\\\.)*\"|\'(?:[^\'\\\\]|\\\\.)*\'", .string)
        ]

    lazy var pattern: String = patterns
        .map {"(\($0.0))"}
        .joined(separator: "|")

    func colorize(_ input: String, theme: ThemeManager.Theme) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: input,
                                                         attributes: TokenKind.regular.attributes(for: theme))

        let regex = try! NSRegularExpression(pattern: pattern, options: []) // swiftlint:disable:this force_try
        let results = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))

        for result in results {
            let kind = patterns[result.matchId].1

            let attributes: [NSAttributedString.Key: Any]
            let value = (input as NSString).substring(with: result.range)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if kind == .identifier {
                if isKeyword(identifier: value) {
                    attributes = TokenKind.keyword.attributes(for: theme)
                } else {
                    attributes = kind.attributes(for: theme)
                }
            } else if kind == .functionCall {
                if knownFunctions.contains(value) {
                    attributes = kind.attributes(for: theme)
                } else {
                    attributes = TokenKind.error.attributes(for: theme)
                }
            } else {
                attributes = kind.attributes(for: theme)
            }

            attributedString.addAttributes(attributes, range: result.range)
        }

        return attributedString
    }

    func isKeyword(identifier: String) -> Bool {
        let keywords = ["if", "else"]
        return keywords.contains(identifier)
    }
}

fileprivate extension NSTextCheckingResult {
    var matchId: Int {
        return (1..<numberOfRanges).filter {range(at: $0).length != 0}.first! - 1
    }
}

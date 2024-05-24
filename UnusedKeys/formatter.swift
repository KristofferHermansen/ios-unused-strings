//
//  formatter.swift
//  UnusedKeys
//
//  Created by Assylbek Issatayev on 08/06/2021.
//

import Foundation

final class Formatter {
    func formatSwiftgenLocalizeString(key: String) -> String {
        var components = key.components(separatedBy: "_")
        for (index, component) in components.enumerated() {
            components[index] = component.capitalized
        }
        let lastIndex = components.count - 1
        let lastWord = components[lastIndex]
        components[lastIndex] = lastWord.lowercasingFirstLetter()
        let joined = components.joined(separator: ".")
        return "L10n." + joined
    }
}

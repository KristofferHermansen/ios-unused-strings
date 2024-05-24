#!/usr/bin/env xcrun swift

import Foundation

let dispatchGroup = DispatchGroup()
let serialWriterQueue = DispatchQueue(label: "writer")
let globalQueue = DispatchQueue.global()
let finder = Finder()
let parser = Parser()
let formatter = Formatter()

func start(stringsDirectory: String, rootDirectories: [String]) -> [String] {
    var result: [String] = []
    let sourceCode = finder.mergeAllSourceCodeIn(rootDirectories, extensions: ["swift"]).lowercased()
    let stringsFiles = finder.findFilesIn([stringsDirectory], withExtensions: ["strings"], filter: "da.")

    guard let stringsFile = stringsFiles.first else {
        return result
    }

    dispatchGroup.enter()
    globalQueue.async {
        let stringsContent = finder.contentsOfFile(stringsFile)
        let identifiers = parser.extractStringIdentifiersFrom(stringsContent)
        print("⚪️ Found a total of \(identifiers.count) keys")
        let unusedIdentifiers = identifiers.filter { identifier in
            let string = formatter.formatSwiftgenLocalizeString(key: identifier).lowercased()
            return !sourceCode.contains(string)
        }

        if unusedIdentifiers.isEmpty == false {
            serialWriterQueue.async {
                result += unusedIdentifiers
                dispatchGroup.leave()
            }
        } else {
            dispatchGroup.leave()
        }
    }
    dispatchGroup.wait()

    return result
}

// MARK: - CommandLine

if CommandLine.arguments.count > 2 {
    var args = CommandLine.arguments
    args.removeFirst()
    let stringsDirectory = args.removeFirst()
    let rootDirectories = args
    let date = Date()
    print("⚪️ Starting")
    let keys = start(stringsDirectory: stringsDirectory, rootDirectories: rootDirectories)
    keys.sorted().forEach { print($0) }
    print("⚪️ Unused strings were detected: \(keys.count)")
    print("🟢 Finished in \(Int(-date.timeIntervalSinceNow)) sec")
} else {
    print("🔴 Please provide a strings directory and directories for source code files as command line arguments. Aborting")
}

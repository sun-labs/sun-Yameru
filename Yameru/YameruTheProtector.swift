//
//  USBProtector.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-04.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation

struct USBDevice {
    var name: String
    var at: String
}

class YameruTheProtector {
    /// credits: https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild
    func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return output
    }
    func lockComputer () -> String {
        return self.shell("/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend")
    }
    
    
    
    func getUSBDevices () -> [[String: String]] {
        let spOutput = self.shell("ioreg -p IOUSB")
        let replaced = spOutput
            .replacingOccurrences(of: "+-o", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "|", with: "")
        let lines = replaced.split(separator: "\n")
        let cleanLines = lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        var devices: [[String: String]] = []
        for line in cleanLines { // for each device
            var device: [String: String] = [:]
            let infos = line.components(separatedBy: " <")
            let nameAndLoc = infos[0]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: "@")
            print(nameAndLoc)
            let name = String(nameAndLoc[0])
            if (name == "Root") { // root controller not needed, skip
                continue
            }
            let location = String(nameAndLoc[1])
            device["name"] = name
            device["location"] = location
            let details = infos[1]
                .split(separator: ",")
                .map {
                    $0
                    .replacingOccurrences(of: ">", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            for detail in details { // for each info
                if detail.contains(" ") {
                    let keyVal = detail.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                    let key = String(keyVal[0])
                    let val = String(keyVal[1])
                    device[key] = val
                } else {
                    device[detail] = "true"
                }
            }
            devices.append(device)
        }
        return devices
    }
}

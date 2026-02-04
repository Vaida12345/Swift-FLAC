//
//  main.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import SwiftFLAC
import SwiftAIFF
import BitwiseOperators
import DetailedDescription


let url = URL(fileURLWithPath: "/Users/vaida/Downloads/1489 B Mary  Garden - Clair de Lune.flac")
let container = try FLACContainer(at: url, options: .decodeMetadataOnly)

detailedPrint(container)

//
//if #available(macOS 13.0, *) {
//    try printData(Data(original.sounds[0].soundData)[0..<10000000]).write(to: .desktopDirectory.appending(path: "original.txt"), atomically: true, encoding: .utf8)
//    try printData(Data(new.sounds[0].soundData)[0..<10000000]).write(to: .desktopDirectory.appending(path: "new.txt"), atomically: true, encoding: .utf8)
//} else {
//    // Fallback on earlier versions
//}
//
//print(original.sounds[0].soundData == new.sounds[0].soundData)
//
//func printData(_ data: Data) -> String {
//    var decoder = BitsDecoder(data)
//    var index = 0
//    var result = ""
//    while let next = try? decoder.decodeInt(encoding: .signed(bits: 24)) {
//        result += "[\(index)], \(next)\n"
//        index += 1
//    }
//    
//    return result
//}

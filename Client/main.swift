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


//let url = URL(fileURLWithPath: "/Users/vaida/Music/mora/Evan Call/TVアニメ『葬送のフリーレン』Original Soundtrack/01-Journey of a Lifetime ~ Frieren Main Theme.flac")
//
//let container = try FLACContainer(at: url)
////detailedPrint(container)
//
//func extractData(from container: FLACContainer) -> Data {
//    var result = Data()
//    
//    // Assuming verbatim encoding 24 bit
//    for frame in container.frames {
//        let bytesPerSample = frame.header.bitsPerSample / 8
//        let frameDataMerged = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: frame.header.blockSize * frame.header.channelAssignment.channelCount * bytesPerSample)
//        
//        for (subframeIndex, subframe) in frame.subframes.enumerated() {
//            if case let .verbatim(data) = subframe.payload {
//                data.data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
//                    buffer.withMemoryRebound(to: UInt8.self) { buffer in
//                        for index in stride(from: 0, to: buffer.count / 3, by: 1) {
//                            frameDataMerged.initializeElement(at: (index * 2 + subframeIndex) * 3, to: buffer[index * 3])
//                            frameDataMerged.initializeElement(at: (index * 2 + subframeIndex) * 3 + 1, to: buffer[index * 3 + 1])
//                            frameDataMerged.initializeElement(at: (index * 2 + subframeIndex) * 3 + 2, to: buffer[index * 3 + 2])
//                        }
//                    }
//                }
//            }
//        }
//        
//        result.append(Data(frameDataMerged))
//        frameDataMerged.deallocate()
//    }
//    
//    return result
//}

//let data = extractData(from: container)
//print(data[data.startIndex + 100000 ..< data.startIndex + 100100].binaryDigits)


//let url = URL(fileURLWithPath: "/Users/vaida/Desktop/01-Journey of a Lifetime ~ Frieren Main Theme-AIFF.aiff")
//
//let container = try AIFFContainer(at: url)

//if #available(macOS 13.0, *) {
//    try AIFFContainer(channelsCount: 2, sampleSize: 24, sampleRate: 48000, soundData: data).write(to: .desktopDirectory.appending(path: "file.aiff"))
//} else {
//    // Fallback on earlier versions
//}
//detailedPrint(container)

//let data = container.sounds[0].soundData
//print(data[data.startIndex + 100000 ..< data.startIndex + 100100].binaryDigits)
// 0b11111111_11111101_11101101_11111111_11111111_11000110_11111111_11111110_00101110_11111111_11111111_10101011_11111111_11111110_10101000_11111111_11111111_10001101_11111111_11111110_01001010_11111111_11111111_00001001_11111111_11111101_10010111_11111111_11111110_11000110_11111111_11111100_11001100_11111111_11111111_00100010_11111111_11111101_11111000_11111111_11111111_00001010_11111111_11111110_00100101_11111111_11111110_11000001_11111111_11111110_10100101_11111111_11111111_00101110_11111111_11111111_00010100_11111111_11111111_10101100_11111111_11111110_00100001_00000000_00000000_00001010_11111111_11111110_01101100_00000000_00000000_00000000_11111111_11111110_10011110_00000000_00000000_01001111_11111111_11111111_00100100_00000000_00000000_10110001_11111111_11111110_11000101_00000000_00000000_10011000_11111111_11111110_01000001_00000000_00000000_10001011_11111111_11111110_10010010_00000000




let url = URL(fileURLWithPath: "/Users/vaida/Desktop/heavy compress.flac")

let container = try FLACContainer(at: url)
detailedPrint(container)

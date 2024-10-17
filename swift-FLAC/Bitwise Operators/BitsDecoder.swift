//
//  BitsDecoder.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


internal struct BitsDecoder {
    
    let data: Data
    
    var bitIndex: Int
    
    
    init(_ data: consuming Data) {
        self.data = data
        self.bitIndex = 0
    }
    
//    mutating func read(bitsCount: Int) -> Data? {
//        let lowerBound = bitIndex
//        self.bitIndex += bitsCount
//        guard bitIndex <= data.count * 8 else { return nil }
//        
//        return data[lowerBound ..< bitIndex]
//    }
    
    mutating func readInteger(bitsCount: Int) -> Int? {
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        self.bitIndex += bitsCount
        guard bitIndex <= data.count * 8 else { return nil }
        
        let (endIndex, endOffset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        let buffer = data[index ..< endIndex + (endOffset == 0 ? 0 : 1)]
        
        return nil
    }
    
    
    static func decodeInteger(_ buffer: Data) -> Int {
        precondition(buffer.count < 8, "Integer too large")
        
        var result: Int = 0
        for (_, element) in buffer.enumerated() {
            if result == 0 {
                // do not shift
            } else {
                result <<= 8
            }
            result |= Int(element)
        }
        
        return result
    }
    
}

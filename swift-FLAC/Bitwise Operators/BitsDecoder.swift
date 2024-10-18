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
    
    init(_ decoder: consuming BytesDecoder) {
        self.data = decoder.data
        self.bitIndex = decoder.index * 8
    }
    
//    mutating func read(bitsCount: Int) -> Data? {
//        let lowerBound = bitIndex
//        self.bitIndex += bitsCount
//        guard bitIndex <= data.count * 8 else { return nil }
//        
//        return data[lowerBound ..< bitIndex]
//    }
    
    /// Seek to given bit index.
    mutating func seek(to offset: Int) {
        self.bitIndex = offset
    }
    
    mutating func decodeInteger(bitsCount: Int) throws(DecodeError) -> Int {
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        self.bitIndex += bitsCount
        guard bitIndex <= data.count * 8 else { throw .outOfBounds }
        
        let (endIndex, endOffset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        assert(endIndex + (endOffset == 0 ? 0 : 1) <= data.count)
        var buffer = data[index ..< endIndex + (endOffset == 0 ? 0 : 1)]
        
        buffer <<= offset
        
        // now align right
        if endOffset != 0 {
            buffer >>= (UInt8.bitWidth - endOffset) + offset
        }
        
        return BitsDecoder.decodeInteger(buffer)
    }
    
    mutating func decodeBool() throws(DecodeError) -> Bool {
        self.bitIndex += 1
        guard bitIndex <= data.count * 8 else { throw .outOfBounds }
        
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        
        return data[index] & (1 << (UInt8.bitWidth - offset)) != 0
    }
    
    mutating func decodeData(bytesCount: Int) throws(DecodeError) -> Data {
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        self.bitIndex += bytesCount * 8
        guard bitIndex <= data.count * 8 else { throw .outOfBounds }
        
        let (endIndex, endOffset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        var buffer = data[index ..< endIndex + (endOffset == 0 ? 0 : 1)]
        
        buffer <<= offset
        
        if buffer.count > bytesCount {
            buffer.removeLast()
        }
        
        assert(buffer.count == bytesCount)
        return buffer
    }
    
    mutating func decodeString(bytesCount: Int) throws(DecodeError) -> String {
        let data = try self.decodeData(bytesCount: bytesCount)
        guard let string = String(data: data, encoding: .utf8) else { throw .invalidString }
        return string
    }
    
    static func decodeInteger(_ buffer: Data, isBigEndian: Bool = true) -> Int {
        precondition(buffer.count <= 8, "Integer too large")
        
        if isBigEndian {
            var result: UInt = 0
            for (_, element) in buffer.enumerated() {
                if result == 0 {
                    // do not shift
                } else {
                    result <<= 8
                }
                result |= UInt(element)
            }
            
            return Int(result)
        } else {
            var result: UInt = 0
            for (index, element) in buffer.enumerated() {
                result |= UInt(element) << (8 * index)
            }
            
            return Int(result)
        }
    }
    
    
    enum DecodeError: Error {
        case outOfBounds
        case invalidString
    }
    
}

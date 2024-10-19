//
//  BitsDecoder.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


public struct BitsDecoder {
    
    public let data: Data
    
    public var bitIndex: Int
    
    
    public init(_ data: consuming Data) {
        self.data = data
        self.bitIndex = 0
    }
    
    public init(_ decoder: consuming BytesDecoder) {
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
    public mutating func seek(to offset: Int) {
        self.bitIndex = offset
    }
    
    public mutating func decodeInteger(bitsCount: Int) throws(DecodeError) -> Int {
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        self.bitIndex += bitsCount
        guard bitIndex <= data.count * 8 else { throw .outOfBounds }
        
        let (endIndex, endOffset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        assert(endIndex + (endOffset == 0 ? 0 : 1) <= data.count)
        var buffer = data[data.startIndex + index ... data.startIndex + endIndex + (endOffset == 0 ? -1 : 0)]
        
        buffer <<= offset
        
        // now align right
        if endOffset != 0 {
            buffer >>= (UInt8.bitWidth - endOffset) + offset
        } else {
            buffer >>= offset
        }
        
        return BitsDecoder.decodeInteger(buffer)
    }
    
    
//    public mutating func
//    
//    /// Decode as the specified type.
//    ///
//    /// When type is signed, necessary measures were made to ensure the return value still represents the encoded value.
//    ///
//    /// - precondition: `bitesCount` \< `type.bitWidth`
//    public mutating func decode<T>(bitesCount: Int, as type: T.Type) -> T where T: FixedWidthInteger {
//        precondition(bitesCount < type.bitWidth)
//        
//        if type.isSigned {
//            
//        } else {
//            
//        }
//    }
    
    public mutating func decodeBool() throws(DecodeError) -> Bool {
        self.bitIndex += 1
        guard bitIndex <= data.count * 8 else { throw .outOfBounds }
        
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        
        return data[index] & (1 << (UInt8.bitWidth - offset)) != 0
    }
    
    public mutating func decodeData(bytesCount: Int) throws(DecodeError) -> Data {
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        self.bitIndex += bytesCount * 8
        guard bitIndex <= data.count * 8 else { throw .outOfBounds }
        
        let (endIndex, endOffset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        var buffer = data[data.startIndex + index ..< data.startIndex + endIndex + (endOffset == 0 ? 0 : 1)]
        
        buffer <<= offset
        
        if buffer.count > bytesCount {
            buffer.removeLast()
        }
        
        assert(buffer.count == bytesCount)
        return buffer
    }
    
    public mutating func decodeString(bytesCount: Int) throws(DecodeError) -> String {
        let data = try self.decodeData(bytesCount: bytesCount)
        guard let string = String(data: data, encoding: .utf8) else { throw .invalidString }
        return string
    }
    
    public static func decodeInteger(_ buffer: Data, isBigEndian: Bool = true) -> Int {
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
    
    
    public enum DecodeError: Error {
        case outOfBounds
        case invalidString
    }
    
}

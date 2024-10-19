//
//  BytesDecoder.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


public struct BytesDecoder {
    
    public let data: Data
    
    public var index: Int
    
    
    public init(_ data: Data) {
        self.data = data
        self.index = 0
    }
    
    public mutating func decodeData(bytesCount: Int) throws(DecodeError) -> Data {
        let index = self.index
        self.index += bytesCount
        guard self.index <= self.data.count else { throw .outOfBounds }
        
        return self.data[data.startIndex + index..<data.startIndex + self.index]
    }
    
    public mutating func decodeNext() throws(DecodeError) -> UInt8 {
        guard self.index < self.data.count else { throw .outOfBounds }
        defer { self.index += 1 }
        
        return self.data[self.index]
    }
    
    public mutating func decodeString(bytesCount: Int, encoding: String.Encoding) throws(DecodeError) -> String {
        let data = try self.decodeData(bytesCount: bytesCount)
        guard let string = String(data: data, encoding: encoding) else { throw .invalidString }
        return string
    }
    
    public mutating func decodeInteger(bytesCount: Int, isBigEndian: Bool = true) throws(DecodeError) -> Int {
        let data = try self.decodeData(bytesCount: bytesCount)
        return BitsDecoder.decodeInteger(data, isBigEndian: isBigEndian)
    }
    
    public mutating func decode<T>(_ type: T.Type = T.self, isBigEndian: Bool = true) throws(DecodeError) -> T where T: BinaryInteger & FixedWidthInteger {
        let buffer = try self.decodeData(bytesCount: T.bitWidth / 8)
        
        if isBigEndian {
            return T(data: Data(buffer.reversed()))
        } else {
            return T(data: buffer)
        }
    }
    
    public enum DecodeError: Error {
        case outOfBounds
        case invalidString
    }
    
}

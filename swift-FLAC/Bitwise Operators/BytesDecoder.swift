//
//  BytesDecoder.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


internal struct BytesDecoder {
    
    let data: Data
    
    var index: Int
    
    
    init(_ data: Data) {
        self.data = data
        self.index = 0
    }
    
    mutating func decodeData(bytesCount: Int) throws(DecodeError) -> Data {
        let index = self.index
        self.index += bytesCount
        guard self.index < self.data.count else { throw .outOfBounds }
        
        return self.data[index..<self.index]
    }
    
    mutating func decodeString(bytesCount: Int, encoding: String.Encoding) throws(DecodeError) -> String {
        let data = try self.decodeData(bytesCount: bytesCount)
        guard let string = String(data: data, encoding: encoding) else { throw .invalidString }
        return string
    }
    
    mutating func decodeInteger(bytesCount: Int, isBigEndian: Bool = true) throws(DecodeError) -> Int {
        let data = try self.decodeData(bytesCount: bytesCount)
        return BitsDecoder.decodeInteger(data, isBigEndian: isBigEndian)
    }
    
    enum DecodeError: Error {
        case outOfBounds
        case invalidString
    }
    
}

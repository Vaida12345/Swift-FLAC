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
    
    /// Seek to given bit index.
    public mutating func seek(to offset: Int) {
        self.bitIndex = offset
    }
    
    @available(*, deprecated, renamed: "decodeInt(encoding:)", message: "Use `decodeInt(encoding:)` instead to decode properly.")
    public mutating func decodeInteger(bitsCount: Int) throws(DecodeError) -> Int {
        let buffer = try self.decodePartialData(bitsCount: bitsCount)
        return BitsDecoder.decodeInteger(buffer)
    }
    
    /// Decode the buffer as `Int` using the given `encoding`.
    ///
    /// - SeeAlso: ``decode(bitsCount:as:endianness:)``
    public mutating func decodeInt(encoding: IntegerEncoding) throws(DecodeError) -> Int {
        switch encoding {
        case .unary:
            var i = 0
            while try self.decodeBool() == false {
                i += 1
            }
            return i
            
        case let ._unsigned(bits, endianness):
            return try Int(self.decode(bitsCount: bits, as: UInt64.self, endianness: endianness))
            
        case let ._signed(bits, endianness):
            return try self.decode(bitsCount: bits, as: Int.self, endianness: endianness)
            
        case .utf8:
            let head = try self.decode(bitsCount: 8, as: UInt8.self)
            guard let length = UTF8.width(startsWith: head) else { throw .invalidEncoding(encoding) }
            var total = try Array(self.decodeData(bytesCount: length - 1))
            total.insert(head, at: 0)
            return BitsDecoder.decodeInteger(Data(total))
        }
    }
    
    /// Returns a data segment large enough to contain `bitsCount` bits.
    ///
    /// - Returns: Only the trailing `bitsCount` bits are relevant. The leading `data.count * 8 - bitsCount` bits are wasted, and filled with zeros.
    public mutating func decodePartialData(bitsCount: Int) throws(DecodeError) -> Data {
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
        
        if (buffer.count > (bitsCount + 7) / 8) {
            assert(buffer.count == (bitsCount + 7) / 8 + 1)
            return buffer[(buffer.startIndex + 1)...]
        } else {
            return buffer
        }
    }
    
    /// Decode as the specified type.
    ///
    /// When type is signed, necessary measures were made to ensure the return value still represents the encoded value.
    ///
    /// - Tip: When decoding an unsigned integer, always retrieve as `UInt`, then cast to `Int`. ``decodeInt(encoding:)``
    ///
    /// A signed value will be decoded using *two's complement*.
    ///
    /// - precondition: `bitsCount` \< `type.bitWidth`
    ///
    /// - Returns: An endianness-independent value.
    public mutating func decode<T>(bitsCount: Int, as type: T.Type = T.self, endianness: Endianness = .bigEndian) throws(DecodeError) -> T where T: FixedWidthInteger {
        precondition(bitsCount <= type.bitWidth, "The result could overflow when stored in \(T.self).")
        precondition(bitsCount <= 64, "The result could overflow UInt64, which is used as intermediate storage.")
        
        let buffer = try self.decodePartialData(bitsCount: bitsCount)
        
        var uint64: UInt64 = 0
        
        switch endianness {
        case .bigEndian:
            for element in buffer {
                uint64 <<= 8
                uint64 |= UInt64(element)
            }
        case .littleEndian:
            for (index, element) in buffer.enumerated() {
                uint64 |= UInt64(element) << (8 * index)
            }
        }
        
        if type.isSigned {
            // check for sign
            let isPositive = uint64 & 1 << (bitsCount - 1) == 0
            if isPositive {
                // it is the same as unsigned integer
                return T(uint64)
            } else {
                // get the absolute value
                // make leading bits one, then when inverted, they will become zero.
                uint64 |= ~0 << (bitsCount - 1)
                let absolute = ~uint64 &+ 1
                return ~T(absolute) &+ 1
            }
        } else {
            return T(uint64)
        }
    }
    
    public mutating func decodeBool() throws(DecodeError) -> Bool {
        guard bitIndex < data.count * 8 else { throw .outOfBounds }
        defer { self.bitIndex += 1 }
        
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        
        return data[data.startIndex + index] & (1 << (UInt8.bitWidth - offset - 1)) != 0
    }
    
    public mutating func decodeData(bytesCount: Int) throws(DecodeError) -> Data {
        let (index, offset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        self.bitIndex += bytesCount * 8
        guard bitIndex <= data.count * 8 else { throw .outOfBounds }
        
        let (endIndex, endOffset) = bitIndex.quotientAndRemainder(dividingBy: 8)
        var buffer = data[data.startIndex + index ..< data.startIndex + endIndex + (endOffset == 0 ? 0 : 1)]
        
        // copy on write, when `offset` is `zero`, it does nothing and returns.
        buffer <<= offset
        
        if buffer.count > bytesCount {
            assert(buffer.count == bytesCount + 1)
            return buffer[0..<buffer.count + buffer.startIndex - 1]
        } else {
            return buffer
        }
    }
    
    public mutating func decodeString(bytesCount: Int, encoding: String.Encoding) throws(DecodeError) -> String {
        let data = try self.decodeData(bytesCount: bytesCount)
        guard let string = String(data: data, encoding: encoding) else { throw .invalidString }
        return string
    }
    
    public static func decodeInteger(_ buffer: Data, endianness: Endianness = .bigEndian) -> Int {
        precondition(buffer.count <= 8, "Integer too large")
        
        switch endianness {
        case .bigEndian:
            var result: UInt = 0
            for element in buffer {
                result <<= 8
                result |= UInt(element)
            }
            
            return Int(result)
            
        case .littleEndian:
            var result: UInt = 0
            for (index, element) in buffer.enumerated() {
                result |= UInt(element) << (8 * index)
            }
            
            return Int(result)
        }
    }
    
    
    public enum DecodeError: Error, Equatable {
        case outOfBounds
        case invalidString
        case invalidEncoding(IntegerEncoding)
    }
    
    public enum Endianness: Sendable, Equatable {
        case bigEndian
        case littleEndian
        
        /// The endianness of the current platform.
        public static var platform: Endianness {
            // test value, 1
            if Int(1).bigEndian == 1 {
                assert(Int(1).littleEndian != 1)
                return .bigEndian
            } else {
                assert(Int(1).littleEndian == 1)
                return .littleEndian
            }
        }
    }
    
    public enum IntegerEncoding: Sendable, Equatable {
        /// In unary encoding, the number is represented by a series of zeros followed by a single one.
        ///
        /// For example, the number 4 would be encoded as `00001`.
        case unary
        /// The integer is encoded as an unsigned integer.
        case _unsigned(bits: Int, endianness: Endianness)
        /// The integer is encoded as an signed integer.
        ///
        /// Necessary measures were made to ensure the return value still represents the encoded value.
        ///
        /// A signed value will be decoded using *two's complement*.
        case _signed(bits: Int, endianness: Endianness)
        /// `UTF-8` encoded number.
        case utf8
        
        
        /// The integer is encoded as an unsigned integer.
        public static func unsigned(bits: Int, endianness: Endianness = .bigEndian) -> IntegerEncoding {
            return ._unsigned(bits: bits, endianness: endianness)
        }
        
        /// The integer is encoded as an signed integer.
        ///
        /// Necessary measures were made to ensure the return value still represents the encoded value.
        ///
        /// A signed value will be decoded using *two's complement*.
        public static func signed(bits: Int, endianness: Endianness = .bigEndian) -> IntegerEncoding {
            ._signed(bits: bits, endianness: endianness)
        }
    }
    
}


private extension Unicode.UTF8 {
    
    /// Returns `nil` if it is not a start byte, otherwise returns the byte length of the character.
    static func width(startsWith byte: Unicode.UTF8.CodeUnit) -> Int? {
        guard byte & 0b1100_0000 != 0b1000_0000 else { return nil } // lead, starts with 10
        
        if (byte & 0b1000_0000) == 0b0000_0000 { // same as isASCII, starts with 0
            return 1
        } else if (byte & 0b1110_0000) == 0b1100_0000 { // starts with 110
            return 2
        } else if (byte & 0b1111_0000) == 0b1110_0000 { // starts with 1110
            return 3
        } else if (byte & 0b1111_1000) == 0b1111_0000 { // starts with 11110
            return 4
        }
        
        fatalError()
    }
    
}

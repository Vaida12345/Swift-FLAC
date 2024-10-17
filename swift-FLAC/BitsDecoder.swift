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


extension Data {
    
    /// Returns the result of shifting a value’s binary representation the specified number of digits to the left.
    ///
    /// As there are unlimited bits, shifting to the left would not result in any ambiguity.
    ///
    /// - Parameters:
    ///   - lhs: The value to shift.
    ///   - rhs: The number of bits to shift lhs to the left.
    @inlinable
    public static func << (lhs: Data, rhs: Int) -> Data {
        var lhs = lhs
        lhs <<= rhs
        return lhs
    }
    
    /// Returns the result of shifting a value’s binary representation the specified number of digits to the left.
    ///
    /// As there are unlimited bits, shifting to the left would not result in any ambiguity.
    ///
    /// - Parameters:
    ///   - lhs: The value to shift.
    ///   - rhs: The number of bits to shift lhs to the left.
    public static func <<= (lhs: inout Data, rhs: Int) {
        guard rhs.signum() != -1 else { lhs >>= abs(rhs); return }
        
        
        var (removed, highOffset) = rhs.quotientAndRemainder(dividingBy: UInt8.bitWidth)
        let lowOffset = UInt8.bitWidth &- highOffset
        
        lhs.withUnsafeMutableBytes { lhs in
            while removed > 0 {
                // remove first
                var index = 1
                while index < lhs.count {
                    lhs[index - 1] = lhs[index]
                    
                    index &+= 1
                }
                lhs[lhs.count &- 1] = 0
                
                removed &-= 1
            }
            
            var index = 0
            while index < lhs.count - 1 {
                lhs[index] = lhs[index] << highOffset | lhs[index &+ 1] >> lowOffset
                
                index &+= 1
            }
            lhs[lhs.count &- 1] <<= highOffset
        }
    }
    
    /// Returns the result of shifting a value’s binary representation the specified number of digits to the right.
    ///
    /// As there are unlimited bits, shifting to the left would not result in any ambiguity.
    ///
    /// Shifting more than the bit width would result in zero.
    ///
    /// - Parameters:
    ///   - lhs: The value to shift.
    ///   - rhs: The number of bits to shift lhs to the right.
    @inlinable
    public static func >> (lhs: Data, rhs: Int) -> Data {
        var lhs = lhs
        lhs >>= rhs
        return lhs
    }
    
    /// Returns the result of shifting a value’s binary representation the specified number of digits to the right.
    ///
    /// As there are unlimited bits, shifting to the left would not result in any ambiguity.
    ///
    /// Shifting more than the bit width would result in zero.
    ///
    /// - Parameters:
    ///   - lhs: The value to shift.
    ///   - rhs: The number of bits to shift lhs to the right.
    public static func >>= (lhs: inout Data, rhs: Int) {
        guard rhs.signum() != -1 else { lhs <<= abs(rhs); return }
        
//        let _result = Int(rhs).quotientAndRemainder(dividingBy: UInt8.bitWidth)
//        let _highShift = _result.quotient
//        
//        lhs.removeLast(_highShift)
//        
//        let lowOffset = _result.remainder
//        let highOffset = UInt8.bitWidth &- lowOffset
//        
//        guard _result.remainder != 0 else { return } // all good!
//        
//        for i in stride(from: lhs.count-1, to: 0, by: -1) {
//            lhs[i] = lhs[i&-1] << highOffset | lhs[i] >> lowOffset
//        }
        
        var (removed, lowOffset) = rhs.quotientAndRemainder(dividingBy: UInt8.bitWidth)
        let highOffset = UInt8.bitWidth &- lowOffset
        
        while removed > 0 {
            // remove last
            var index = lhs.count - 1
            while index > 0 {
                lhs[index] = lhs[index - 1]
                
                index &-= 1
            }
            lhs[0] = 0
            
            
            removed &-= 1
        }
        
        
        var index = lhs.count &- 1
        while index > 0 {
            lhs[index] = lhs[index &- 1] << highOffset | lhs[index] >> lowOffset
            
            index &-= 1
        }
        lhs[0] >>= lowOffset
    }
    
}

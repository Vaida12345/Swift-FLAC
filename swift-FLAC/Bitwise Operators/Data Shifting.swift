//
//  Data Shifting.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


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
        
        var (removed, lowOffset) = rhs.quotientAndRemainder(dividingBy: UInt8.bitWidth)
        let highOffset = UInt8.bitWidth &- lowOffset
        
        lhs.withUnsafeMutableBytes { lhs in
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
    
}


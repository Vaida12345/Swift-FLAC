//
//  MutableBuffer.swift
//  Swift-FLAC
//
//  Created by Vaida on 11/6/24.
//

import Foundation


public struct MutableBuffer {
    
    let pointer: UnsafeMutablePointer<UInt8>
    
    let count: Int
    
    private let startIndex: Int
    
    func deallocate() {
        self.pointer.deallocate()
    }
    
    init(pointer: UnsafeMutablePointer<UInt8>, count: Int, startIndex: Int) {
        self.pointer = pointer
        self.count = count
        self.startIndex = startIndex
    }
    
    init(data: Data) {
        self.pointer = .allocate(capacity: data.count)
        data.copyBytes(to: pointer, count: data.count)
        self.count = data.count
        self.startIndex = 0
    }
    
    subscript(index: Int) -> UInt8 {
        get {
            (self.pointer + index + startIndex).pointee
        }
        set {
            (self.pointer + index + startIndex).initialize(to: newValue)
        }
    }
    
    subscript(_ range: Range<Int>) -> MutableBuffer {
        MutableBuffer(pointer: self.pointer, count: range.upperBound - range.lowerBound, startIndex: range.lowerBound + self.startIndex)
    }
    
    subscript(_ range: PartialRangeFrom<Int>) -> MutableBuffer {
        MutableBuffer(pointer: self.pointer, count: self.count - range.lowerBound, startIndex: range.lowerBound + startIndex)
    }
}


extension MutableBuffer {
    
    /// Returns the result of shifting a value’s binary representation the specified number of digits to the left.
    ///
    /// As there are unlimited bits, shifting to the left would not result in any ambiguity.
    ///
    /// - Parameters:
    ///   - lhs: The value to shift.
    ///   - rhs: The number of bits to shift lhs to the left.
    @inlinable
    public static func << (lhs: MutableBuffer, rhs: Int) -> MutableBuffer {
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
    public static func <<= (lhs: inout MutableBuffer, rhs: Int) {
        guard rhs != 0 else { return }
        guard rhs.signum() != -1 else { lhs >>= abs(rhs); return }
        
        var (removed, highOffset) = rhs.quotientAndRemainder(dividingBy: UInt8.bitWidth)
        let lowOffset = UInt8.bitWidth &- highOffset
        
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
    public static func >> (lhs: MutableBuffer, rhs: Int) -> MutableBuffer {
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
    public static func >>= (lhs: inout MutableBuffer, rhs: Int) {
        guard rhs != 0 else { return }
        guard rhs.signum() != -1 else { lhs <<= abs(rhs); return }
        
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

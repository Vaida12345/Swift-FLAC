//
//  DataTests.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Testing
import Foundation
@testable
import swiftFLAC


@Suite
struct DataTests {
    
    @Test
    func leftShift() {
        let lhs = Data([0b0001_0000, 0b1000_0000])
        let rhs = Data([0b001_00001, 0b0000_0000])
        #expect(lhs << 1 == rhs)
    }
    
    @Test
    func rightShift() {
        let lhs = Data([0b0001_0001, 0b1000_0000])
        let rhs = Data([0b0000_1000, 0b1100_0000])
        #expect(lhs >> 1 == rhs)
    }
    
    @Test
    func leftShiftCross() {
        let lhs = Data([0b0001_0000, 0b1000_1000])
        let rhs = Data([0b0001_0000, 0b0000_0000])
        #expect(lhs << 9 == rhs)
    }
    
    @Test
    func rightShiftCross() {
        let lhs = Data([0b0001_0001, 0b1000_0000])
        let rhs = Data([0b0000_0000, 0b0000_1000])
        #expect(lhs >> 9 == rhs)
    }
    
    @Test(arguments: -64...64)
    func shiftUInt64(bits: Int) {
        let value = UInt64.random(in: 0...UInt64.max)
        let valueData = Data(value.data.reversed())
        
        let valueDataShifted = valueData << bits
        let valueShiftedData = Data((value << bits).data.reversed())
        
        #expect(valueDataShifted == valueShiftedData, "\(value.data.binaryDigits) << \(bits) = \(valueShiftedData) ≠ \(valueDataShifted)")
    }
    
}


extension BinaryInteger {
    
    /// The raw data that made up the binary integer.
    @inlinable
    var data: Data {
        withUnsafePointer(to: self) { pointer in
            pointer.withMemoryRebound(to: UInt8.self, capacity: bitWidth / 8) { pointer in
                Data(bytes: pointer, count: bitWidth / 8)
            }
        }
    }
    
    /// Creates a integer using the given data.
    ///
    /// - Note: If the width of `data` is greater than `Self.max`, if `self` is fixed width, the result is truncated.
    @inlinable
    init(data: Data) {
        let tuple = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer { tuple.deallocate() }
        
        data.copyBytes(to: tuple, count: data.count)
        
        self = tuple.withMemoryRebound(to: Self.self, capacity: 1) { $0.pointee }
    }
    
}


extension Data {
    
    
    /// Explicitly present the underlying digits.
    ///
    /// Please note that arm64 uses little-endian for the order of bytes.
    ///
    /// ```swift
    /// let value: UInt16 = 0b1000101
    ///
    /// value // 16
    /// value.data.binaryDigits // 0b01000101_00000000
    /// ```
    @inlinable
    var binaryDigits: String {
        self.withUnsafeBytes { buffer in
            let buffer = buffer.bindMemory(to: UInt8.self)
            
            var results: String = "0b"
            results.reserveCapacity(self.count + buffer.count + 1 + 2)
            
            for i in 0..<buffer.count {
                for ii in 0..<8 {
                    let pivot = (0b10000000 as UInt8) >> ii
                    results.append("\(buffer[i] & pivot == pivot ? "1" : "0")")
                }
                
                
                if i == buffer.count - 2 {
                    results.append("_")
                }
            }
            
            return results
        }
    }
    
    
}

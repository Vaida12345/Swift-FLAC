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

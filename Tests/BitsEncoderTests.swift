//
//  BitsEncoderTests.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/21/24.
//

import Testing
@testable
import BitwiseOperators
import Foundation


@Suite
struct BitsEncoderTests {
    
    func assertGet(_ lhs: BitsEncoder, data: UInt64, bitWidth: Int) {
        let _data = lhs.data(alignment: .right)
        #expect(_data.1 == bitWidth)
        
        let dataCount = (bitWidth+7)/8
        #expect(_data.0.binaryDigits == data.bigEndian.data[(8-dataCount) ..< 8].binaryDigits)
        
        
        let _left = lhs.data(alignment: .left)
        #expect(_left.1 == bitWidth)
        #expect(_left.0.binaryDigits == (data.bigEndian.data[(8-dataCount) ..< 8] << (bitWidth % 8 == 0 ? 0 : UInt8.bitWidth - (bitWidth % 8))).binaryDigits)
    }
    
    @Test
    func encodeBits() {
        var encoder = BitsEncoder()
        encoder.encode(0b1, bitWidth: 1)
        
        assertGet(encoder, data: 0b1, bitWidth: 1)
        
        encoder.encode(0b1, bitWidth: 1)
        assertGet(encoder, data: 0b11, bitWidth: 2)
        
        encoder.encode(0b1010101, bitWidth: 7)
        assertGet(encoder, data: 0b1_11010101, bitWidth: 9)
        
        encoder.encode(0b1010101, bitWidth: 7)
        assertGet(encoder, data: 0b1_11010101_1010101, bitWidth: 16)
    }
    
    @Test
    func encodeDifferentWidth() {
        var encoder1 = BitsEncoder()
        encoder1.encode(0b1, bitWidth: 1)
        
        var encoder2 = BitsEncoder()
        encoder2.encode((0b1 as Int32).bigEndian.data, bitWidth: 1)
        
        #expect(encoder1.data(alignment: .right) == encoder2.data(alignment: .right))
    }
    
}


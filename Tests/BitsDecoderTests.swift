//
//  BitsDecoderTests.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Testing
@testable
import SwiftFLAC
import Foundation
import BitwiseOperators


@Suite
struct BitsDecoderTests {
    
    @Test
    func decodeInteger() throws {
        let bits: UInt16 = 0b0001_0000_1000_0000
        var decoder = BitsDecoder(Data(bits.data.reversed()))
        decoder.seek(to: 3)
        
        #expect(try decoder.decodeInteger(bitsCount: 6) == 33)
    }
    
    @Test
    func decodeInteger2() throws {
        let bits = Data([0b00000100, 0b10000000])
        var decoder = BitsDecoder(bits)
        
        try #expect(decoder.decodeInteger(bitsCount: 16) == 128 + 1024)
    }
    
    @Test
    func decodeInteger3() throws {
        let bits = Data([0b00000100, 0b10000000])
        var decoder = BitsDecoder(bits)
        decoder.seek(to: 3)
        
        try #expect(decoder.decodeInteger(bitsCount: 5) == 4)
    }
    
    @Test
    func decodeLittleEndianInteger() throws {
        let int = Int.random(in: 0...Int.max)
        
        #expect(int == BitsDecoder.decodeInteger(int.data, isBigEndian: false))
    }
    
    @Test
    func decodeBool() throws {
        let bits: UInt16 = 0b0001_0000_1000_0000
        var decoder = BitsDecoder(Data(bits.data.reversed()))
        decoder.seek(to: 3)
        
        #expect(try decoder.decodeBool())
        
        #expect(try !decoder.decodeBool())
    }
    
    @Test
    func decodeData() throws {
        
        let bits: UInt32 = 0b00010000_10000000_11001010_00000000
        var decoder = BitsDecoder(Data(bits.data.reversed()))
        decoder.seek(to: 3)
        
        #expect(try decoder.decodeData(bytesCount: 2) == Data([0b10000100, 0b00000110]))
        
    }
}

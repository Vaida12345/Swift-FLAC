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
        print(bits.binaryDigits)
        var decoder = BitsDecoder(bits)
        
        try #expect(decoder.decodeInteger(bitsCount: 16) == 128 + 1024)
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
}

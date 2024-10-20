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
        
        #expect(try decoder.decodeInt(encoding: .unsigned(bits: 6)) == 33)
    }
    
    @Test
    func decodeInteger2() throws {
        let bits = Data([0b00000100, 0b10000000])
        var decoder = BitsDecoder(bits)
        
        try #expect(decoder.decodeInt(encoding: .unsigned(bits: 16)) == 128 + 1024)
    }
    
    @Test
    func decodeInteger3() throws {
        let bits = Data([0b00000100, 0b10000000])
        var decoder = BitsDecoder(bits)
        decoder.seek(to: 3)
        
        try #expect(decoder.decodeInt(encoding: .unsigned(bits: 5)) == 4)
    }
    
    @Test
    func decodeLittleEndianInteger() throws {
        let int = Int.random(in: 0...Int.max)
        
        #expect(int == BitsDecoder.decodeInteger(int.data, endianness: .littleEndian))
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
    
    @Test
    func decodePartialData() throws {
        let data = Data([0b0001_0010, 0b1000_0000, 0b1100_1010, 0b0000_0000])
        var decoder = BitsDecoder(data)
        
        #expect(try decoder.decodePartialData(bitsCount: 3) == Data([0b0000_0000]))
        #expect(try decoder.decodePartialData(bitsCount: 1) == Data([0b0000_0001]))
        #expect(try decoder.decodePartialData(bitsCount: 4) == Data([0b0000_0010]))
        #expect(try decoder.decodePartialData(bitsCount: 2) == Data([0b0000_0010]))
        #expect(try decoder.decodePartialData(bitsCount: 7) == Data([0b0000_0001]))
        #expect(try decoder.decodePartialData(bitsCount: 9) == Data([0b0000_0001, 0b0010_1000]))
        #expect(try decoder.decodePartialData(bitsCount: 6) == Data([0b0000_0000]))
        
        #expect(throws: BitsDecoder.DecodeError.outOfBounds) {
            try decoder.decodePartialData(bitsCount: 1)
        }
    }
    
    @Test
    func decodeAsInt() throws {
        func _decode3bit(from data: UInt8) throws -> Int {
            let data = Data([data])
            var decoder = BitsDecoder(data)
            decoder.seek(to: 5)
            return try decoder.decode(bitsCount: 3, as: Int.self)
        }
        
        try #expect(_decode3bit(from: 0b111) == -1)
        try #expect(_decode3bit(from: 0b110) == -2)
        try #expect(_decode3bit(from: 0b101) == -3)
        try #expect(_decode3bit(from: 0b100) == -4)
        try #expect(_decode3bit(from: 0b011) == 3)
        try #expect(_decode3bit(from: 0b010) == 2)
        try #expect(_decode3bit(from: 0b001) == 1)
        try #expect(_decode3bit(from: 0b000) == 0)
    }
    
    @Test
    func decodeAsUInt() throws {
        func _decode3bit(from data: UInt8) throws -> UInt {
            let data = Data([data])
            var decoder = BitsDecoder(data)
            decoder.seek(to: 5)
            return try decoder.decode(bitsCount: 3, as: UInt.self)
        }
        
        try #expect(_decode3bit(from: 0) == 0)
        try #expect(_decode3bit(from: 1) == 1)
        try #expect(_decode3bit(from: 2) == 2)
        try #expect(_decode3bit(from: 3) == 3)
        try #expect(_decode3bit(from: 4) == 4)
        try #expect(_decode3bit(from: 5) == 5)
        try #expect(_decode3bit(from: 6) == 6)
        try #expect(_decode3bit(from: 7) == 7)
    }
    
    @Test
    func decodeUnaryInt() throws {
        for i in 0..<8 {
            let data = Data([1 << (7 - i)])
            var decoder = BitsDecoder(data)
            try #expect(decoder.decodeInt(encoding: .unary) == i)
        }
    }
    
}

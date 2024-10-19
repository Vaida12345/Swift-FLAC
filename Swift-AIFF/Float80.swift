//
//  Float80.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/19/24.
//

import Foundation
import BitwiseOperators


public struct Float80: CustomStringConvertible {
    
    // MARK: - Instance Stored Properties
    
    let signExponent: RawExponent
    
    public let significandBitPattern: RawSignificand
    
    
    // MARK: - Computed Instance Properties
    
    public var sign: FloatingPointSign {
        signExponent >> 15 == 0 ? .plus : .minus
    }
    
    public var exponentBitPattern: UInt16 {
        signExponent & 0b01111111_11111111
    }
    
    public static var significandBitCount: Int {
        64
    }
    
    public static var exponentBitCount: Int {
        15
    }
    
    public var description: String {
        Double(self).description
    }
    
    public var bigEndianData: Data {
        var data = Data()
        data.append(contentsOf: self.signExponent.bigEndian.data)
        data.append(contentsOf: self.significandBitPattern.bigEndian.data)
        
        return data
    }
    
    
    public init(
        sign: FloatingPointSign,
        exponentBitPattern: Self.RawExponent,
        significandBitPattern: Self.RawSignificand
    ) {
        assert(exponentBitPattern >> 15 == 0, "first bit in exponent must be zero")
        
        self.signExponent = sign == .plus ? exponentBitPattern : exponentBitPattern | 1 << 15
        self.significandBitPattern = significandBitPattern
    }
    
    public init(data: Data) {
        assert(data.count == 10)
        
        self.signExponent = data.withUnsafeBytes { buffer in
            buffer[0..<2].reversed().withUnsafeBytes { buffer in
                buffer.load(as: RawExponent.self)
            }
        }
        
        self.significandBitPattern = data.withUnsafeBytes { buffer in
            buffer[2..<10].reversed().withUnsafeBytes { buffer in
                buffer.bindMemory(to: RawSignificand.self).baseAddress!.pointee
            }
        }
    }
    
    public init(_ double: Double) {
        let sign = double.sign
        let exponent = double.exponent
        let bias = pow2(Float80.exponentBitCount - 1) - 1
        let exponentBits = UInt16(exponent + bias)
        
        // Convert the significand into a bit representation
        var significandBits = double.significandBitPattern << (Float80.significandBitCount - Double.significandBitCount - 1)
        
        // float80 always has implicit 1
        significandBits |= 1 << 63
        
        self.init(sign: sign, exponentBitPattern: exponentBits, significandBitPattern: significandBits)
    }
    
    
    public typealias RawExponent = UInt16
    
    public typealias RawSignificand = UInt64
    
}


public extension Double {
    
    init(_ float80: Float80) {
//        print(float80.signExponent.data.binaryDigits)
//        print(float80.sign)
//        print(float80.exponentBitPattern.data.binaryDigits, float80.exponentBitPattern)
//        print(float80.significandBitPattern.data.binaryDigits)
        
        let bias = pow2(Float80.exponentBitCount - 1) - 1
        let exponent = Int(float80.exponentBitPattern) - bias
        let signum: Double = float80.sign == .minus ? -1 : 1
        var significand: Double = 0
        
        for i in stride(from: Float80.significandBitCount - 1, through: 0, by: -1) {
            let offset = Float80.RawSignificand.bitWidth - i - 1
            if float80.significandBitPattern & (1 << offset) != 0 {
                significand += pow(2, -Double(i))
            }
        }
        
        self = signum * pow(2, Double(exponent)) * significand
    }
    
}


private func pow2(_ by: Int) -> Int {
    1 << by
}

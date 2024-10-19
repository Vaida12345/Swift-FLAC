//
//  Data Extensions.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


public extension BinaryInteger {
    
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
    /// - Precondition: If `data` length is not equal to bit width, the result is undefined.
    @inlinable
    init(data: Data) {
        self = data.withUnsafeBytes { (tuple: UnsafeRawBufferPointer) in
            tuple.bindMemory(to: Self.self).baseAddress!.pointee
        }
    }
    
}


public extension Data {
    
    
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
                
                if i != buffer.count - 1 {
                    results.append("_")
                }
            }
            
            return results
        }
    }
    
    
}

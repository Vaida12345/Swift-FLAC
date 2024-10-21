//
//  BitsEncoder.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/21/24.
//

import Foundation


public struct BitsEncoder {
    
    public private(set) var data: Data
    
    /// The offset within the last `Data`. Hence the offset is always within 0-7.
    public private(set) var offset: Int
    
    
    /// Obtain the encoded data, right aligned.
    ///
    /// - Returns: The trailing `bitWidth` bits of `data` is valid.
    public func getRightAligned() -> (data: Data, bitWidth: Int) {
        if offset == 0 {
            return (data: data, bitWidth: data.count * 8)
        } else {
            return (data: data >> (UInt8.bitWidth - offset), bitWidth: (data.count - 1) * 8 + offset)
        }
    }
    
    /// Obtain the encoded data, left aligned.
    ///
    /// - Returns: The leading `bitWidth` bits of `data` is valid.
    public func getLeftAligned() -> (data: Data, bitWidth: Int) {
        if offset == 0 {
            return (data: data, bitWidth: data.count * 8)
        } else {
            return (data: data, bitWidth: (data.count - 1) * 8 + offset)
        }
    }
    
    /// The encode the trailing `bitWidth` bits in `value`.
    ///
    /// - Invariant: ``BitsEncoder`` would *always* encode in ``BitsDecoder/Endianness/bigEndian``.
    public mutating func encode(_ value: UInt64, bitWidth: Int) {
        var data = value.bigEndian.data
        
        // start by aligning the bits to the left
        data <<= (UInt64.bitWidth - bitWidth)
        
        if offset == 0 {
            // append the relevant data
            self.data.append(data[data.startIndex ..< data.startIndex + (bitWidth + 7) / 8])
            self.offset = bitWidth % 8
        } else {
            // right shift by the current offset
            if UInt64.bitWidth - bitWidth < offset {
                // no enough room for right shift, add trailing data.
                data.append(UInt8.zero)
            }
            data >>= offset
            data = data[data.startIndex ..< data.startIndex + (bitWidth + 7 + offset) / 8]
            
            // now append everything
            // offset is non-zero, hence there is always room in the last byte in `self.data`
            let head = data.removeFirst()
            self.data[self.data.endIndex - 1] |= head
            self.data.append(data)
            
            // update offset
            self.offset = (offset + bitWidth) % 8
        }
    }
    
    
    public init() {
        self.data = Data()
        self.offset = 0
    }
    
}

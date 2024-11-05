//
//  BitsEncoder.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/21/24.
//

import Foundation


public struct BitsEncoder {
    
    /// Left aligned data.
    private(set) var data: Data
    
    /// The offset within the last `Data`. Hence the offset is always within 0-7.
    private(set) var offset: Int
    
    
    /// Obtain the encoded data, right aligned.
    ///
    /// - Returns: The trailing `bitWidth` bits of `data` is valid.
    @available(*, deprecated, renamed: "data(alignment:)")
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
    @available(*, deprecated, renamed: "data(alignment:)")
    public func getLeftAligned() -> (data: Data, bitWidth: Int) {
        if offset == 0 {
            return (data: data, bitWidth: data.count * 8)
        } else {
            return (data: data, bitWidth: (data.count - 1) * 8 + offset)
        }
    }
    
    /// Obtains the encoded data.
    ///
    /// If `bitWidth` is divisible by `8`, both alignments would yield the same result.
    ///
    /// ```swift
    /// encoder.encode(0b10, bitWidth: 2)
    ///
    /// encoder.data(alignment: .left)
    /// // 
    /// ```
    ///
    /// - Parameters:
    ///   - alignment: The alignment of the returned data.
    ///
    /// > Returns:
    /// > - ``Alignment/left``: The leading `bitWidth` bits are valid.
    /// > - ``Alignment/right``: The trailing `bitWidth` bits are valid.
    public func data(alignment: Alignment) -> (data: Data, bitWidth: Int) {
        if offset == 0 {
            return (data: data, bitWidth: data.count * 8)
        } else {
            switch alignment {
            case .left:
                return (data: data, bitWidth: (data.count - 1) * 8 + offset)
            case .right:
                return (data: data >> (UInt8.bitWidth - offset), bitWidth: (data.count - 1) * 8 + offset)
            }
        }
    }
    
    /// The encode the trailing `bitWidth` bits in `value`.
    ///
    /// As this function only encodes the least significant (trailing) `bitWidth` bits, the `value` should be in big endian.
    public mutating func encode(_ value: Data, bitWidth: Int) {
        var data = value
        let fullBitWidth = value.count * 8
        
        // start by aligning the bits to the left
        data <<= (fullBitWidth - bitWidth)
        
        if offset == 0 {
            // append the relevant data
            self.data.append(data[data.startIndex ..< data.startIndex + (bitWidth + 7) / 8])
            self.offset = bitWidth % 8
        } else {
            // right shift by the current offset
            if fullBitWidth - bitWidth < offset {
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
    
    /// The encode the trailing `bitWidth` bits in `value`.
    ///
    /// - Invariant: ``BitsEncoder`` would *always* encode in ``BitsDecoder/Endianness/bigEndian``.
    public mutating func encode(_ value: UInt64, bitWidth: Int) {
        let data = value.bigEndian.data
        self.encode(data, bitWidth: bitWidth)
    }
    
    
    public init() {
        self.data = Data()
        self.offset = 0
    }
    
    public enum Alignment {
        /// Indicates the data are left aligned. The leading *n* bits are valid.
        case left
        /// Indicates the data are right aligned. The trailing *n* bits are valid.
        case right
    }
    
}

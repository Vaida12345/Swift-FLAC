//
//  Verbatim Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct Verbatim: CustomStringConvertible {
        
        public let data: Data
        
        public var description: String {
            data.description
        }
        
        init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subheader: FLACContainer.Frame.Subframe.Header) throws {
            assert(header.bitsPerSample * header.blockSize % 8 == 0)
            self.data = try handler.decodeData(bytesCount: header.bitsPerSample * header.blockSize / 8)
        }
        
        public func _encodedSequence(
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) -> [Int] {
            var decoder = BitsDecoder(self.data)
            return (0 ..< header.blockSize).map { _ in
                try! decoder.decodeInt(encoding: .signed(bits: header.bitsPerSample))
            }
        }
        
        /// Writes the contents of this payload to the given buffer.
        ///
        /// - Parameters:
        ///   - buffer: The destination. Shifted in the way that the index of `0` is aligned with the payload data.
        ///   - stride: The distance in *samples* between the start of two consecutive sample.
        ///   - header: The frame header
        public func _write(
            to buffer: UnsafeMutablePointer<UInt8>,
            stride: Int,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) {
            let bytesPerSample = header.bitsPerSample / 8
            
            self.data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                ptr.withMemoryRebound(to: UInt8.self) { ptr in
                    var index = 0
                    var destIndex = 0
                    
                    while index < ptr.count / bytesPerSample {
                        var ii = 0
                        while ii < bytesPerSample {
                            (buffer + destIndex).initialize(to: ptr[index * bytesPerSample + ii])
                            
                            destIndex &+= 1
                            ii &+= 1
                        }
                        
                        destIndex &+= (stride &- 1) * bytesPerSample
                        index &+= 1
                    }
                }
            }
        }
        
    }
    
}

//
//  Constant Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct Constant: CustomStringConvertible, PayloadProtocol {
        
        public let sample: Int
        
        public var description: String {
            sample.description
        }
        
        init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subheader: FLACContainer.Frame.Subframe.Header, channelIndex: Int) throws {
            assert(header.bitsPerSample % 8 == 0)
            self.sample = try handler.decodeInt(encoding: .signed(bits: header.bitsPerSample - subheader.wastedBitsPerSample + (header.isSideChannel(channelIndex: channelIndex) ? 1 : 0)))
        }
        
        public func _encodedSequence(
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) -> [Int] {
            [Int](repeating: sample, count: header.blockSize)
        }
        
        public func _write(
            to buffer: UnsafeMutablePointer<UInt8>,
            stride: Int,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) {
            var destIndex = 0
            let bytesPerSample = header.bitsPerSample / 8
            
            withUnsafePointer(to: sample.bigEndian) { pointer in
                pointer.withMemoryRebound(to: UInt8.self, capacity: 32 / 8) { pointer in
                    var iteratorIndex = 0
                    while iteratorIndex < header.blockSize {
                        var ii = 0
                        while ii < bytesPerSample {
                            (buffer + destIndex).initialize(to: pointer[ii])
                            
                            destIndex &+= 1
                            ii &+= 1
                        }
                        
                        destIndex &+= (stride &- 1) * bytesPerSample
                        iteratorIndex &+= 1
                    }
                }
            }
        }
        
    }
    
}

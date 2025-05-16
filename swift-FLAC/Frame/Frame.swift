//
//  Frame.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators
import Accelerate


extension FLACContainer {
    
    /// A Raw FLAC Frame
    ///
    /// A frame header plus one or more subframes.
    public struct Frame: DetailedStringConvertible {
        
        public let header: Header
        
        /// One subframe per channel.
        public let subframes: [Subframe]
        
        /// CRC-16 (polynomial = x^16 + x^15 + x^2 + x^0, initialized with 0) of everything before the crc, back to and including the frame header sync code
        public let checksum: UInt16
        
        
        init(handler: inout BitsDecoder, streamInfo: FLACContainer.Metadata.StreamInfoBlock, index: Int) throws {
            let header = try Header(handler: &handler, streamInfo: streamInfo, index: index)
            
            self.header = header
            let channelCount = self.header.channelAssignment.channelCount
            self.subframes = try (0..<channelCount).map { i in
                let frame = try Subframe(handler: &handler, header: header, subframeIndex: i)
                return frame
            }
            
            if !handler.bitIndex.isMultiple(of: 8) {
                let paddings = try handler.decodeInt(encoding: .unsigned(bits: 8 - handler.bitIndex % 8))
                guard paddings == 0 else {
                    throw DecodeError.invalidPadding
                }
            }
            assert(handler.bitIndex.isMultiple(of: 8))
            
            self.checksum = try handler.decode(bitsCount: 16, as: UInt16.self)
        }

        /// Encodes the data of this frame as interleaved to the given buffer.
        public func write(
            to buffer: UnsafeMutablePointer<UInt8>
        ) {
            let bytesPerSample = self.header.bitsPerSample / 8
            
            if case .independent(let channelsCount) = self.header.channelAssignment {
                var channelIndex = 0
                
                while channelIndex < channelsCount {
                    let subframe = self.subframes[channelIndex]
                    subframe.payload._write(to: buffer + channelIndex * bytesPerSample, stride: channelsCount, header: self.header, subheader: subframe.header)
                    
                    channelIndex &+= 1
                }
                
                return
            }
            
            let channel0 = self.subframes[0].payload._encodedSequence(header: header, subheader: self.subframes[0].header)
            let channel1 = self.subframes[1].payload._encodedSequence(header: header, subheader: self.subframes[1].header)
            
            let leftChannel: (_ channel0: Int, _ channel1: Int) -> Int
            let rightChannel: (_ channel0: Int, _ channel1: Int) -> Int
            
            switch self.header.channelAssignment {
            case .midSideStereo:
                /*
                 To reconstruct the left channel, the corresponding samples in the mid and side subframes are added and the result shifted right by 1 bit,
                 while for the right channel the side channel has to be subtracted from the mid channel and the result shifted right by 1 bit.
                 */
                leftChannel = { mid, side in
                    var mid = mid << 1;
                    mid |= (side & 1); /* i.e. if 'side' is odd... */
                    return (mid + side) >> 1
                }
                
                rightChannel = { mid, side in
                    var mid = mid << 1;
                    mid |= (side & 1); /* i.e. if 'side' is odd... */
                    return (mid - side) >> 1
                }
                
            case .leftSideStereo:
                /*
                 To decode, the right subblock is restored by subtracting the samples in the side subframe from the corresponding samples the left subframe.
                 */
                leftChannel = { left, side in
                    left
                }
                
                rightChannel = { left, side in
                    left - side
                }
                
            case .rightSideStereo:
                /*
                 To decode, the left subblock is restored by adding the samples in the side subframe to the corresponding samples in the right subframe.
                 */
                leftChannel = { side, right in
                    right + side
                }
                
                rightChannel = { side, right in
                    right
                }
                
            case .independent:
                fatalError("already handled")
            }
            
            func encodeSide(_ channel: (_ channel0: Int, _ channel1: Int) -> Int, offset: Int) {
                var destIndex = 0
                let bytesPerSample = header.bitsPerSample / 8
                
                var iteratorIndex = 0
                while iteratorIndex < header.blockSize {
                    // obtain the correct bit width data
                    // swift int is 64bit, flac supports up to 32bit int.
                    withUnsafePointer(to: channel(channel0[iteratorIndex], channel1[iteratorIndex]).bigEndian) { pointer in
                        pointer.withMemoryRebound(to: UInt8.self, capacity: 32 / 8) { pointer in
                            var ii = 0
                            while ii < bytesPerSample {
                                (buffer + destIndex + offset).initialize(to: pointer[ii])
                                
                                destIndex &+= 1
                                ii &+= 1
                            }
                        }
                    }
                    
                    destIndex &+= bytesPerSample
                    iteratorIndex &+= 1
                }
            }
            
            encodeSide(leftChannel, offset: 0)
            encodeSide(rightChannel, offset: bytesPerSample)
        }
        
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.header)
                descriptor.sequence(for: \.subframes)
            }
        }
        
        
        public enum DecodeError: Error {
            case invalidPadding
        }
        
    }
    
}

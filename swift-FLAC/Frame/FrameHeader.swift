//
//  FrameHeader.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame {
    
    public struct Header: CustomDetailedStringConvertible {
        
        public let blockStrategy: BlockStrategy
        
        /// Block size in inter-channel samples
        public private(set) var blockSize: Int
        
        public private(set) var sampleRate: Int?
        
        /// Number of independent channels. Where defined, the channel order follows SMPTE/ITU-R recommendations
        public let channelAssignment: ChannelAssignment
        
        /// Sample size in bits.
        public let bitsPerSample: Int
        
        /// CRC-8 checksum
        ///
        /// CRC-8 (polynomial = x^8 + x^2 + x^1 + x^0, initialized with 0) of everything before the crc, including the sync code
        public let checksum: UInt8
        
        
        init(handler: inout BitsDecoder, streamInfo: FLACContainer.Metadata.StreamInfoBlock) throws {
            guard try handler.decodeInteger(bitsCount: 14) == 0b11111111111110 else {
                // [255, 248...251]
                throw DecodeError.invalidSyncCode
            }
            let _ = try handler.decodeBool()
            let isVariableBlockSize = try handler.decodeBool()
            
            let rawSize = try handler.decodeInteger(bitsCount: 4)
            switch rawSize {
            case 0b0000:
                throw DecodeError.reservedBlockSize
            case 0b0001:
                self.blockSize = 192
            case 0b0010...0b0101:
                self.blockSize = 576 << (rawSize - 2)
            case 0b1000...0b1111:
                self.blockSize = 256 << (rawSize - 8)
            default:
                fatalError()
            }
            
            let rawSampleRate = try handler.decodeInteger(bitsCount: 4)
            switch rawSampleRate {
            case 0b0000:
                self.sampleRate = streamInfo.sampleRate
            case 0b0001:
                self.sampleRate = 88_200
            case 0b0010:
                self.sampleRate = 176_400
            case 0b0011:
                self.sampleRate = 192_000
            case 0b0100:
                self.sampleRate = 8_000
            case 0b0101:
                self.sampleRate = 16_000
            case 0b0110:
                self.sampleRate = 22_050
            case 0b0111:
                self.sampleRate = 24_000
            case 0b1000:
                self.sampleRate = 32_000
            case 0b1001:
                self.sampleRate = 44_100
            case 0b1010:
                self.sampleRate = 48_000
            case 0b1011:
                self.sampleRate = 96_000
            case 0b1111:
                throw DecodeError.invalidSampleRate
            default:
                break
            }
            
            let rawChannelCount = try handler.decodeInteger(bitsCount: 4)
            switch rawChannelCount {
            case 0b0000...0b0111:
                self.channelAssignment = .channels(count: rawChannelCount + 1)
            case 0b1000:
                self.channelAssignment = .leftSideStereo
            case 0b1001:
                self.channelAssignment = .rightSideStereo
            case 0b1010:
                self.channelAssignment = .midSideStereo
            default:
                throw DecodeError.reservedChannelAssignment
            }
            
            let rawSampleSize = try handler.decodeInteger(bitsCount: 3)
            self.bitsPerSample = switch rawSampleSize {
            case 0b000: streamInfo.bitsPerSample
            case 0b001: 8
            case 0b010: 12
            case 0b011: throw DecodeError.reservedBitsPerSample
            case 0b100: 16
            case 0b101: 20
            case 0b110: 24
            case 0b111: 32
            default: fatalError()
            }
            
            let _ = try handler.decodeBool()
            
            let utf8head = try UInt8(handler.decodeInteger(bitsCount: 8))
            guard let utf8length = UTF8.width(startsWith: utf8head) else { throw DecodeError.blockSizeEncodingIsNotUTF8 }
            var utf8Total = try Array(handler.decodeData(bytesCount: utf8length - 1))
            utf8Total.insert(utf8head, at: 0)
            let utf8Number = BitsDecoder.decodeInteger(Data(utf8Total))
            
            if isVariableBlockSize {
                self.blockStrategy = .variableBlockSize(sampleNumber: utf8Number)
            } else {
                self.blockStrategy = .fixedBlockSize(frameNumber: utf8Number)
            }
            
            switch rawSize {
            case 0b0110:
                // get 8 bit (blocksize-1) from end of header
                self.blockSize = try handler.decodeInteger(bitsCount: 8)
            case 0b0111:
                // 0111 : get 16 bit (blocksize-1) from end of header
                self.blockSize = try handler.decodeInteger(bitsCount: 16)
            default:
                break
            }
            
            switch rawSampleRate {
            case 0b1100:
                // 1100 : get 8 bit sample rate (in kHz) from end of header
                self.sampleRate = try handler.decodeInteger(bitsCount: 8) * 1000
            case 0b1101:
                // 1101 : get 16 bit sample rate (in Hz) from end of header
                self.sampleRate = try handler.decodeInteger(bitsCount: 16)
            case 0b1110:
                // 1110 : get 16 bit sample rate (in tens of Hz) from end of header
                self.sampleRate = try handler.decodeInteger(bitsCount: 16) * 10
            default:
                break
            }
            
            let data = try handler.decodeData(bytesCount: 1)
            self.checksum = data[data.startIndex]
        }
        
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Header>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.blockStrategy)
                descriptor.value(for: \.blockSize)
                descriptor.optional(for: \.sampleRate)
                descriptor.value(for: \.channelAssignment)
                descriptor.value(for: \.bitsPerSample)
            }
        }
        
        
        public enum DecodeError: Error {
            case invalidSyncCode
            case invalidSampleRate
            case reservedChannelAssignment
            case reservedBitsPerSample
            case reservedBlockSize
            case blockSizeEncodingIsNotUTF8
        }
        
        public enum BlockStrategy {
            /// fixed-blocksize stream; frame header encodes the frame number
            ///
            /// the frame header encodes the frame number as above, and the frame's starting sample number will be the frame number times the blocksize
            case fixedBlockSize(frameNumber: Int)
            /// variable-blocksize stream; frame header encodes the sample number
            ///
            /// the frame header encodes the frame's starting sample number itself
            case variableBlockSize(sampleNumber: Int)
        }
        
        public enum ChannelAssignment {
            /// Number of independent channels. Where defined, the channel order follows SMPTE/ITU-R recommendations
            case channels(count: Int)
            /// left/side stereo: channel 0 is the left channel, channel 1 is the side(difference) channel
            case leftSideStereo
            /// right/side stereo: channel 0 is the side(difference) channel, channel 1 is the right channel
            case rightSideStereo
            /// mid/side stereo: channel 0 is the mid(average) channel, channel 1 is the side(difference) channel
            case midSideStereo
            
            public var channelCount: Int {
                switch self {
                case let .channels(count):
                    return count
                default:
                    return 2
                }
            }
        }
        
    }
    
}


func pow(_ a: Int, _ b: Int) -> Int {
    var result = a
    var index = 1
    while index < b {
        result *= a
        
        index &+= 1
    }
    
    return result
}


extension Unicode.UTF8 {
    
    /// Returns `nil` if it is not a start byte, otherwise returns the byte length of the character.
    static func width(startsWith byte: Unicode.UTF8.CodeUnit) -> Int? {
        guard byte & 0b1100_0000 != 0b1000_0000 else { return nil } // lead, starts with 10
        
        if (byte & 0b1000_0000) == 0b0000_0000 { // same as isASCII, starts with 0
            return 1
        } else if (byte & 0b1110_0000) == 0b1100_0000 { // starts with 110
            return 2
        } else if (byte & 0b1111_0000) == 0b1110_0000 { // starts with 1110
            return 3
        } else if (byte & 0b1111_1000) == 0b1111_0000 { // starts with 11110
            return 4
        }
        
        fatalError()
    }
    
}

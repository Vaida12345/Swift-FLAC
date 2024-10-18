//
//  FrameHeader.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


extension FLACContainer.Frame {
    
    public struct Header {
        
        public let blockStrategy: BlockStrategy
        
        /// Block size in inter-channel samples
        public private(set) var blockSize: Int?
        
        /// If `nil`, get from `STREAMINFO` metadata block
        public private(set) var sampleRate: Int?
        
        /// Number of independent channels. Where defined, the channel order follows SMPTE/ITU-R recommendations
        public let channelAssignment: ChannelAssignment?
        
        /// Sample size in bits.
        ///
        /// If `nil`, get from `STREAMINFO` metadata block
        public let sampleSize: Int?
        
        /// CRC-8 checksum
        ///
        /// CRC-8 (polynomial = x^8 + x^2 + x^1 + x^0, initialized with 0) of everything before the crc, including the sync code
        public let checksum: UInt8
        
        
        init(handler: inout BitsDecoder) throws {
            guard try handler.decodeInteger(bitsCount: 14) == 0b11111111111110 else { throw DecodeError.invalidSyncCode }
            let _ = try handler.decodeBool()
            let isVariableBlockSize = try handler.decodeBool()
            
            let rawSize = try handler.decodeInteger(bitsCount: 4)
            switch rawSize {
            case 0b0000:
                self.blockSize = nil
            case 0b0001:
                self.blockSize = 192
            case 0b0010...0b010:
                self.blockSize = 576 * pow(2, rawSize - 2)
            case 0b1000...0b1111:
                self.blockSize = 256 * pow(2, rawSize - 8)
            default:
                break
            }
            
            let rawSampleRate = try handler.decodeInteger(bitsCount: 4)
            switch rawSampleRate {
            case 0b0000:
                self.sampleRate = nil
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
                self.channelAssignment = nil
            }
            
            let rawSampleSize = try handler.decodeInteger(bitsCount: 3)
            self.sampleSize = switch rawSampleSize {
            case 0b000: nil
            case 0b001: 8
            case 0b010: 12
            case 0b011: nil
            case 0b100: 16
            case 0b101: 20
            case 0b110: 24
            case 0b111: 32
            default: fatalError()
            }
            
            let _ = try handler.decodeBool()
            
            if isVariableBlockSize {
                self.blockStrategy = try .variableBlockSize(sampleNumber: handler.decodeString(bytesCount: 56 / 8))
            } else {
                self.blockStrategy = try .fixedBlockSize(frameNumber: handler.decodeString(bytesCount: 48 / 8))
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
            
            self.checksum = try handler.decodeData(bytesCount: 1)[0]
        }
        
        
        public enum DecodeError: Error {
            case invalidSyncCode
            case invalidSampleRate
        }
        
        public enum BlockStrategy {
            /// fixed-blocksize stream; frame header encodes the frame number
            ///
            /// the frame header encodes the frame number as above, and the frame's starting sample number will be the frame number times the blocksize
            case fixedBlockSize(frameNumber: String)
            /// variable-blocksize stream; frame header encodes the sample number
            ///
            /// the frame header encodes the frame's starting sample number itself
            case variableBlockSize(sampleNumber: String)
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
        }
        
    }
    
}


private func pow(_ a: Int, _ b: Int) -> Int {
    var a = a
    var index = 1
    while index < b {
        a *= a
        
        index &+= 1
    }
    
    return a
}

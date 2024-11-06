//
//  MetadataStreamInfo.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Metadata {
    
    /// This block has information about the whole stream, like sample rate, number of channels, total number of samples, etc.
    public struct StreamInfoBlock: CustomDetailedStringConvertible {
        
        /// The minimum block size (in samples) used in the stream.
        public let minimumBlockSize: Int
        
        /// The maximum block size (in samples) used in the stream. (Minimum blocksize == maximum blocksize) implies a fixed-blocksize stream.
        public let maximumBlockSize: Int
        
        /// The minimum frame size (in bytes) used in the stream. May be 0 to imply the value is not known.
        public let minimumFrameSize: Int
        
        /// The maximum frame size (in bytes) used in the stream. May be 0 to imply the value is not known.
        public let maximumFrameSize: Int
        
        /// Sample rate in Hz. Though 20 bits are available, the maximum sample rate is limited by the structure of frame headers to 655350Hz. Also, a value of 0 is invalid.
        public let sampleRate: Int
        
        /// Number of channels. FLAC supports from 1 to 8 channels
        public let channelsCount: Int
        
        /// Bits per sample. FLAC supports from 4 to 32 bits per sample.
        public let bitsPerSample: Int
        
        /// Total samples in stream. 'Samples' means inter-channel sample, i.e. one second of 44.1Khz audio will have 44100 samples regardless of the number of channels. A value of zero here means the number of total samples is unknown.
        public let samplesCount: Int
        
        /// MD5 signature of the unencoded audio data. This allows the decoder to determine if an error exists in the audio data even when the error does not result in an invalid bitstream.
        public let md5Signature: Data
        
        
        /// FLAC specifies a minimum block size of 16 and a maximum block size of 65535, meaning the bit patterns corresponding to the numbers 0-15 in the minimum blocksize and maximum blocksize fields are invalid.
        init(data: Data) throws {
            var handler = BitsDecoder(data)
            
            let minimumBlockSize = try handler.decodeInt(encoding: .unsigned(bits: 16))
            guard minimumBlockSize >= 16 && minimumBlockSize <= 65535 else { throw DecodeError.invalidBlockSize }
            self.minimumBlockSize = minimumBlockSize
            
            let maximumBlockSize = try handler.decodeInt(encoding: .unsigned(bits: 16))
            guard maximumBlockSize >= 16 && maximumBlockSize <= 65535 else { throw DecodeError.invalidBlockSize }
            self.maximumBlockSize = maximumBlockSize
            
            self.minimumFrameSize = try handler.decodeInt(encoding: .unsigned(bits: 24))
            self.maximumFrameSize = try handler.decodeInt(encoding: .unsigned(bits: 24))
            
            self.sampleRate = try handler.decodeInt(encoding: .unsigned(bits: 20))
            
            self.channelsCount = try handler.decodeInt(encoding: .unsigned(bits: 3)) + 1
            
            self.bitsPerSample = try handler.decodeInt(encoding: .unsigned(bits: 5)) + 1
            
            self.samplesCount = try handler.decodeInt(encoding: .unsigned(bits: 36))
            
            self.md5Signature = try handler.decodeData(bytesCount: 128 / 8)
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Metadata.StreamInfoBlock>) -> any DescriptionBlockProtocol {
            descriptor.container {
                if minimumBlockSize == maximumBlockSize {
                    descriptor.value("blockSize", of: minimumBlockSize)
                } else {
                    descriptor.value(for: \.minimumBlockSize)
                    descriptor.value(for: \.maximumBlockSize)
                }
                
                descriptor.value(for: \.minimumFrameSize)
                descriptor.value(for: \.maximumFrameSize)
                
                descriptor.value(for: \.sampleRate)
                descriptor.value(for: \.channelsCount)
                descriptor.value(for: \.bitsPerSample)
                descriptor.value(for: \.samplesCount)
            }
        }
        
        public enum DecodeError: Error {
            case invalidBlockSize
        }
        
    }
    
}

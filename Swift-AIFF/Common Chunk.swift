//
//  Common Chunk.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/19/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension AIFFContainer {
    
    public struct CommonChunk: CustomDetailedStringConvertible {
        
        /// 4 Byte String.
        ///
        /// For the ease of use, we use `String` instead of `(UInt8, UInt8, UInt8, UInt8)`.
        public let chunkID: String = "COMM"
        
        /// Chunk size, excluding ``chunkID`` and ``chunkSize``.
        public let chunkSize: Int32
        
        public let channelsCount: Int16
        
        /// A set of interleaved sample points is called a sample frame
        ///
        /// the number of sample frames, not the number of bytes nor the number of sample points in the Sound Data Chunk. The total number of sample points in the file is `numSampleFrames` times `numChannels`.
        public let framesCount: UInt32
        
        public let sampleSize: Int16
        
        /// the sample rate at which the sound is to be played back, in sample frames per second
        public let sampleRate: Float80
        
        
        func write(to handle: inout FileHandle) throws {
            if #available(macOS 10.15.4, *) {
                try handle.write(contentsOf: chunkID.data(using: .utf8)!)
                try handle.write(contentsOf: chunkSize.bigEndian.data)
                try handle.write(contentsOf: channelsCount.bigEndian.data)
                try handle.write(contentsOf: framesCount.bigEndian.data)
                try handle.write(contentsOf: sampleSize.bigEndian.data)
                try handle.write(contentsOf: sampleRate.bigEndianData)
            } else {
                handle.write(chunkID.data(using: .utf8)!)
                handle.write(chunkSize.bigEndian.data)
                handle.write(channelsCount.bigEndian.data)
                handle.write(framesCount.bigEndian.data)
                handle.write(sampleSize.bigEndian.data)
                handle.write(sampleRate.bigEndianData)
            }
        }
        
        
        init(handler: inout BytesDecoder) throws {
            let id = try handler.decodeString(bytesCount: 4, encoding: .ascii)
            guard id == "COMM" else { throw DecodeError.invalidChunkID }
            self.chunkSize = try handler.decode()
            let offset = handler.index
            
            self.channelsCount = try handler.decode()
            self.framesCount = try handler.decode()
            self.sampleSize = try handler.decode()
            
            let float80Data = try handler.decodeData(bytesCount: 80 / 8)
            self.sampleRate = Float80(data: float80Data)
            
            assert(handler.index - offset == chunkSize)
        }
        
        public init(channelsCount: Int, sampleSize: Int, sampleRate: Double, soundData: Data) {
            self.chunkSize = 18
            self.channelsCount = Int16(channelsCount)
            self.framesCount = UInt32(soundData.count / channelsCount / (sampleSize / 8))
            self.sampleSize = Int16(sampleSize)
            self.sampleRate = Float80(sampleRate)
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<AIFFContainer.CommonChunk>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.chunkID)
                descriptor.value(for: \.chunkSize)
                descriptor.value(for: \.channelsCount)
                descriptor.value(for: \.framesCount)
                descriptor.value(for: \.sampleSize)
                descriptor.value(for: \.sampleRate)
            }
        }
        
    }
    
}

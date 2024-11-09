//
//  SoundData Chunk.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/19/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension AIFFContainer {
    
    public struct SoundDataChunk: CustomDetailedStringConvertible {
        
        /// 4 Byte String.
        ///
        /// For the ease of use, we use `String` instead of `(UInt8, UInt8, UInt8, UInt8)`.
        public let chunkID: String = "SSND"
        
        /// Chunk size, excluding ``chunkID`` and ``chunkSize``.
        public let chunkSize: Int32
        
        public let offset: UInt32
        
        /// blockSize is used in conjunction with offset for block-aligning sound data.
        ///
        /// It contains the size in bytes of the blocks that sound data is aligned to. As with offset, most applications won't use blockSize and should set it to zero.
        public let blockSize: UInt32
        
        public let soundData: Data
        
        
        func write(to handle: inout FileHandle) throws {
            if #available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *) {
                try handle.write(contentsOf: chunkID.data(using: .utf8)!)
                try handle.write(contentsOf: chunkSize.bigEndian.data)
                try handle.write(contentsOf: offset.bigEndian.data)
                try handle.write(contentsOf: blockSize.bigEndian.data)
                try handle.write(contentsOf: soundData)
            } else {
                handle.write(chunkID.data(using: .utf8)!)
                handle.write(chunkSize.bigEndian.data)
                handle.write(offset.bigEndian.data)
                handle.write(blockSize.bigEndian.data)
                handle.write(soundData)
            }
        }
        
        
        /// Initializer without the ID.
        init(handler: inout BytesDecoder) throws {
            self.chunkSize = try handler.decode()
            var dataSize = Int(chunkSize)
            
            self.offset = try handler.decode()
            dataSize -= MemoryLayout<UInt32>.size
            
            self.blockSize = try handler.decode()
            dataSize -= MemoryLayout<UInt32>.size
            
            self.soundData = try handler.decodeData(bytesCount: dataSize)
        }
        
        init(soundData: Data) {
            self.offset = 0
            self.blockSize = 0
            self.soundData = soundData
            self.chunkSize = Int32(soundData.count) + 8
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<AIFFContainer.SoundDataChunk>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.chunkID)
                descriptor.value(for: \.chunkSize)
                descriptor.value(for: \.offset)
                descriptor.value(for: \.blockSize)
                descriptor.value(for: \.soundData)
            }
        }
        
    }
    
}

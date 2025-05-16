//
//  Raw Chunk.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/19/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension AIFFContainer {
    
    public struct RawChunk: DetailedStringConvertible {
        
        /// 4 Byte String.
        ///
        /// For the ease of use, we use `String` instead of `(UInt8, UInt8, UInt8, UInt8)`.
        public let chunkID: String
        
        /// Chunk size, excluding ``chunkID`` and ``chunkSize``.
        public let chunkSize: Int32
        
        public let data: Data
        
        
        /// Initializer without the ID.
        init(id: String, handler: inout BytesDecoder) throws {
            self.chunkID = id
            self.chunkSize = try handler.decode()
            self.data = try handler.decodeData(bytesCount: Int(chunkSize))
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<AIFFContainer.RawChunk>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.chunkID)
                descriptor.value(for: \.chunkSize)
                descriptor.value(for: \.data)
            }
        }
        
    }
    
}

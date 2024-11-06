//
//  RawMetadata.swift
//  swift-FLAC
//
//  Created by Vaida on 10/17/24.
//

import Foundation
import BitwiseOperators


extension FLACContainer.Metadata {
    
    /// Un-decoded raw field.
    public struct RawMetadata {
        
        public let blockType: BlockType?
        
        public let data: Data
        
        
        init(handler: inout BitsDecoder, metaDataIsLast: inout Bool) throws {
            metaDataIsLast = try handler.decodeBool()
            
            let blockType = try handler.decode(bitsCount: 7, as: UInt8.self)
            switch blockType {
            case 127:
                throw CorruptionError.invalidBlockType
                
            default:
                self.blockType = .init(rawValue: blockType)
            }
            
            let length = try handler.decodeInt(encoding: .unsigned(bits: 24))
            let data = try handler.decodeData(bytesCount: length)
            self.data = data
        }
        
        
        public enum CorruptionError: Error {
            case invalidLastMetadataBlockFlagData
            case invalidBlockType
            case invalidLengthData
            case invalidPayload
        }
        
        public enum BlockType: UInt8 {
            case streamInfo = 0
            case padding
            case application
            case seekTable
            case vorbisComment
            case cueSheet
            case picture
        }
        
    }
    
}

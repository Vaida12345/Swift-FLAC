//
//  RawMetadata.swift
//  swift-FLAC
//
//  Created by Vaida on 10/17/24.
//

import Foundation


extension FLACContainer.Metadata {
    
    public struct RawMetadata {
        
        public let blockType: BlockType?
        
        public let data: Data
        
        
        init(handle: FileHandle, metaDataIsLast: inout Bool) throws {
            guard let headerData = try handle.read(upToCount: 1)?[0] else { throw CorruptionError.invalidLastMetadataBlockFlagData }
            
            switch headerData >> 7 {
            case 1:
                metaDataIsLast = true
            case 0:
                metaDataIsLast = false
            default:
                fatalError()
            }
            
            let blockType = headerData & 0b0111_1111
            switch blockType {
            case 127:
                throw CorruptionError.invalidBlockType
                
            default:
                self.blockType = .init(rawValue: blockType)
            }
            
            guard let lengthData = try handle.read(upToCount: 3) else { throw CorruptionError.invalidLengthData }
            
            let length = BitsDecoder.decodeInteger(lengthData)
            guard let data = try handle.read(upToCount: length) else { throw CorruptionError.invalidPayload }
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

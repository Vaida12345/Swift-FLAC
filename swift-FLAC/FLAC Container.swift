//
//  FLACContainer.swift
//  swift-FLAC
//
//  Created by Vaida on 10/17/24.
//

import Foundation
import DetailedDescription


/// A container for FLAC.
///
/// - SeeAlso: [FLAC Specifications](https://xiph.org/flac/format.html)
public struct FLACContainer: CustomDetailedStringConvertible {
    
    public let metadata: Metadata
    
    
    public init(from source: URL) throws {
        
        let handle = try FileHandle(forReadingFrom: source)
        
        guard let nextData = try handle.read(upToCount: 4),
              String(data: nextData, encoding: .ascii) == "fLaC" else { throw DecodeError.notFLAC }
        
        
        var isLastMetadata = false
        var rawMetadata: [Metadata.RawMetadata] = []
        
        while !isLastMetadata {
            let new = try Metadata.RawMetadata(handle: handle, metaDataIsLast: &isLastMetadata)
            rawMetadata.append(new)
        }
        
        guard rawMetadata.count > 0,
              rawMetadata[0].blockType == .streamInfo,
              let streamInfo = Metadata.StreamInfoBlock(data: rawMetadata[0].data) else {
            throw DecodeError.missingStreamInfo
        }
        
        var metadata = Metadata(streamInfo: streamInfo)
        
        for raw in rawMetadata[1...] {
            switch raw.blockType {
            case .application:
                guard let block = Metadata.ApplicationBlock(data: raw.data) else { throw DecodeError.cannotDecodeApplication }
                metadata.application.append(block)
                
            case .seekTable:
                guard let block = Metadata.SeekTableBlock(data: raw.data) else { throw DecodeError.cannotDecodeSeekTable }
                if metadata.seekTable != nil {
                    throw DecodeError.duplicatedSeekTable
                } else {
                    metadata.seekTable = block
                }
                
            case .vorbisComment:
                if metadata.seekTable != nil {
                    throw DecodeError.duplicatedVorbisComment
                } else {
                    do {
                        let block = try Metadata.VorbisCommentBlock(data: raw.data)
                        metadata.vorbisComment = block
                    } catch {
                        throw DecodeError.cannotDecodeVorbisComment(error)
                    }
                }
                
            default:
                continue
            }
        }
        
        self.metadata = metadata
    }
    
    public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer>) -> any DescriptionBlockProtocol {
        descriptor.container {
            descriptor.value(for: \.metadata)
        }
    }
    
    public enum DecodeError: Error {
        case notFLAC
        case missingStreamInfo
        case cannotDecodeApplication
        case cannotDecodeSeekTable
        case duplicatedSeekTable
        case cannotDecodeVorbisComment(Error)
        case duplicatedVorbisComment
    }
    
}

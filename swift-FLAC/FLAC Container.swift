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
              rawMetadata[0].blockType == .streamInfo else {
            throw DecodeError.missingStreamInfo(NSError())
        }
        
        let streamInfo: Metadata.StreamInfoBlock
        do {
            streamInfo = try Metadata.StreamInfoBlock(data: rawMetadata[0].data)
        } catch {
            throw DecodeError.missingStreamInfo(error)
        }
        
        var metadata = Metadata(streamInfo: streamInfo)
        
        for raw in rawMetadata[1...] {
            switch raw.blockType {
            case .application:
                do {
                    let block = try Metadata.ApplicationBlock(data: raw.data)
                    metadata.application.append(block)
                } catch {
                    throw DecodeError.cannotDecodeApplication(error)
                }
                
            case .seekTable:
                if metadata.seekTable != nil {
                    throw DecodeError.duplicatedSeekTable
                } else {
                    do {
                        let block = try Metadata.SeekTableBlock(data: raw.data)
                        metadata.seekTable = block
                    } catch {
                        throw DecodeError.cannotDecodeSeekTable(error)
                    }
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
                
            case .cueSheet:
                if metadata.cueSheet != nil {
                    throw DecodeError.duplicatedCueSheet
                } else {
                    do {
                        let block = try Metadata.CueSheetBlock(data: raw.data)
                        metadata.cueSheet = block
                    } catch {
                        throw DecodeError.cannotDecodeCueSheet(error)
                    }
                }
                
            case .picture:
                do {
                    let block = try Metadata.PictureBlock(data: raw.data)
                    metadata.pictures.append(block)
                } catch {
                    throw DecodeError.cannotDecodePicture(error)
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
        case missingStreamInfo(Error)
        case cannotDecodeApplication(Error)
        case cannotDecodeSeekTable(Error)
        case duplicatedSeekTable
        case cannotDecodeVorbisComment(Error)
        case duplicatedVorbisComment
        case cannotDecodeCueSheet(Error)
        case duplicatedCueSheet
        case cannotDecodePicture(Error)
    }
    
}

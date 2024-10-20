//
//  FLACContainer.swift
//  swift-FLAC
//
//  Created by Vaida on 10/17/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


/// A container for FLAC.
///
/// - SeeAlso: [FLAC Specifications](https://xiph.org/flac/format.html)
public struct FLACContainer: CustomDetailedStringConvertible {
    
    public let metadata: Metadata
    
    public let frames: [Frame]
    
    
    public init(at url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }
    
    public init(data: Data) throws {
        var handler = BitsDecoder(consume data)
        
        guard try handler.decodeString(bytesCount: 4, encoding: .ascii) == "fLaC" else { throw DecodeError.notFLAC }
        
        var isLastMetadata = false
        var rawMetadata: [Metadata.RawMetadata] = []
        
        while !isLastMetadata {
            let new = try Metadata.RawMetadata(handler: &handler, metaDataIsLast: &isLastMetadata)
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
                
            case .padding:
                continue
                
            default:
                metadata.rawFields.append(raw)
            }
        }
        
        self.metadata = metadata
        
        var frames: [Frame] = []
        while handler.bitIndex < handler.data.count * 8 {
            let frame = try Frame(handler: &handler, streamInfo: streamInfo)
            frames.append(frame)
        }
        self.frames = frames
    }
    
    public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer>) -> any DescriptionBlockProtocol {
        descriptor.container {
            descriptor.value(for: \.metadata)
            descriptor.sequence(for: \.frames)
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

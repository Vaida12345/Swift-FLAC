//
//  FLACContainer.swift
//  swift-FLAC
//
//  Created by Vaida on 10/17/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


/// A FLAC Document.
///
/// In this package, ``FLACContainer`` encapsulates FLAC documents. The ``FLACContainer/metadata-swift.property`` encodes the metadata, and ``FLACContainer/frames`` encodes the raw frames. 
///
/// - SeeAlso: [FLAC Specifications](https://xiph.org/flac/format.html)
public struct FLACContainer: DetailedStringConvertible {
    
    /// The FLAC metadata.
    public let metadata: Metadata
    
    /// The FLAC raw frames.
    public let frames: [Frame]
    
    
    /// Creates a document at the given url.
    public init(at url: URL, options: DecodeOptions? = nil) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data, options: options)
    }
    
    /// Creates a document from the given data.
    public init(data: Data, options: DecodeOptions? = nil) throws {
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
                do {
                    let block = try Metadata.SeekTableBlock(data: raw.data)
                    metadata.seekTable = block
                } catch {
                    throw DecodeError.cannotDecodeSeekTable(error)
                }
                
            case .vorbisComment:
                do {
                    let block = try Metadata.VorbisCommentBlock(data: raw.data)
                    metadata.vorbisComment = block
                } catch {
                    throw DecodeError.cannotDecodeVorbisComment(error)
                }
                
            case .cueSheet:
                do {
                    let block = try Metadata.CueSheetBlock(data: raw.data)
                    metadata.cueSheet = block
                } catch {
                    throw DecodeError.cannotDecodeCueSheet(error)
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
        
        if options != .decodeMetadataOnly {
            var frames: [Frame] = []
            while handler.bitIndex < handler.data.count * 8 {
                let frame = try Frame(handler: &handler, streamInfo: streamInfo, index: frames.count)
                frames.append(frame)
            }
            self.frames = frames
        } else {
            self.frames = []
        }
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
        case cannotDecodeVorbisComment(Error)
        case cannotDecodeCueSheet(Error)
        case cannotDecodePicture(Error)
    }
    
    public enum DecodeOptions {
        case decodeMetadataOnly
    }
    
}

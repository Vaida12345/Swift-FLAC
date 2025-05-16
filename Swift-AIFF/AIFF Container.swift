//
//  AIFF Container.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/19/24.
//

import DetailedDescription
import Foundation
import BitwiseOperators


/// An AIFF file, or, *FORM*
public struct AIFFContainer: DetailedStringConvertible {
    
    /// 4 Byte String.
    ///
    /// For the ease of use, we use `String` instead of `(UInt8, UInt8, UInt8, UInt8)`.
    public let chunkID: String = "FORM"
    
    /// Chunk size, excluding ``chunkID`` and ``chunkSize``.
    public let chunkSize: Int32
    
    /// 4 Byte String.
    public let formType: String = "AIFF"
    
    public let common: CommonChunk
    
    public let sounds: [SoundDataChunk]
    
    public let rawChunks: [RawChunk]
    
    
    public init(data: Data) throws {
        var handler = BytesDecoder(data)
        
        guard try handler.decodeString(bytesCount: 4, encoding: .ascii) == "FORM" else { throw DecodeError.invalidChunkID }
        self.chunkSize = try handler.decode(Int32.self)
        guard try handler.decodeString(bytesCount: 4, encoding: .ascii) == "AIFF" else { throw DecodeError.invalidChunkID }
        
        self.common = try CommonChunk(handler: &handler)
        
        var sounds: [SoundDataChunk] = []
        var raws: [RawChunk] = []
        while handler.index < handler.data.count {
            let id = try handler.decodeString(bytesCount: 4, encoding: .ascii)
            if id == "SSND" {
                try sounds.append(SoundDataChunk(handler: &handler))
            } else {
                try raws.append(RawChunk(id: id, handler: &handler))
            }
            
        }
        self.sounds = sounds
        self.rawChunks = raws
    }
    
    public init(at url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }
    
    public init(channelsCount: Int, sampleSize: Int, sampleRate: Double, soundData: Data) {
        let common = CommonChunk(channelsCount: channelsCount, sampleSize: sampleSize, sampleRate: sampleRate, soundData: soundData)
        let sound = SoundDataChunk(soundData: soundData)
        
        self.common = common
        self.sounds = [sound]
        self.rawChunks = []
        
        self.chunkSize = 16 + common.chunkSize + sound.chunkSize
    }
    
    public func write(to url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        
        try Data().write(to: url)
        var handle = try FileHandle(forWritingTo: url)
        try self.write(to: &handle)
    }
    
    public func write(to handle: inout FileHandle) throws {
        if #available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *) {
            try handle.write(contentsOf: chunkID.data(using: .utf8)!)
            try handle.write(contentsOf: chunkSize.bigEndian.data)
            try handle.write(contentsOf: formType.data(using: .utf8)!)
        } else {
            handle.write(chunkID.data(using: .utf8)!)
            handle.write(chunkSize.bigEndian.data)
            handle.write(formType.data(using: .utf8)!)
        }
        
        try self.common.write(to: &handle)
        for sound in sounds {
            try sound.write(to: &handle)
        }
    }
    
    public func detailedDescription(using descriptor: DetailedDescription.Descriptor<AIFFContainer>) -> any DescriptionBlockProtocol {
        descriptor.container {
            descriptor.value(for: \.chunkID)
            descriptor.value(for: \.chunkSize)
            descriptor.value(for: \.formType)
            descriptor.value(for: \.common)
            descriptor.sequence(for: \.sounds)
            descriptor.sequence(for: \.rawChunks)
        }
    }
    
    public enum DecodeError: Error {
        case invalidChunkID
        case invalidFormType
    }
    
}

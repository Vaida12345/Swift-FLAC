//
//  Container + Data.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import SwiftAIFF


extension FLACContainer {
    
    /// Extract interleaved audio data.
    ///
    /// - Bug: Currently requires all frames to be `verbatim`.
    public func interleavedAudioData() -> Data {
        
        let length = self.metadata.streamInfo.samplesCount * self.metadata.streamInfo.channelsCount * self.metadata.streamInfo.bitsPerSample / 8
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: length)
        var accumulativeWidth = 0
    
        
        var frameIndex = 0
        while frameIndex < self.frames.count {
            let frame = self.frames[frameIndex]
            let bytesPerSample = frame.header.bitsPerSample / 8
            let length = frame.header.blockSize * frame.header.channelAssignment.channelCount * bytesPerSample
            let frameDataMerged = UnsafeMutableBufferPointer<UInt8>(start: buffer.baseAddress! + accumulativeWidth, count: length)
    
            var subframeIndex = 0
            while subframeIndex < frame.subframes.count {
                let subframe = frame.subframes[subframeIndex]
                if case let .verbatim(data) = subframe.payload {
                    data.data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                        buffer.withMemoryRebound(to: UInt8.self) { buffer in
                            var index = 0
                            while index < buffer.count / 3 {
                                frameDataMerged.initializeElement(at: (index * 2 + subframeIndex) * 3, to: buffer[index * 3])
                                frameDataMerged.initializeElement(at: (index * 2 + subframeIndex) * 3 + 1, to: buffer[index * 3 + 1])
                                frameDataMerged.initializeElement(at: (index * 2 + subframeIndex) * 3 + 2, to: buffer[index * 3 + 2])
                                
                                index &+= 1
                            }
                        }
                    }
                } else {
                    fatalError("non-verbatim subframe is currently not supported. This will be fixed in a future commit.")
                }
                
                subframeIndex &+= 1
            }
    
            frameIndex &+= 1
            accumulativeWidth &+= length
        }
    
        return Data(bytesNoCopy: buffer.baseAddress!, count: length, deallocator: .free)
    }
    
    /// Writes the document as AIFF.
    public func write(to url: URL) throws {
        let data = self.interleavedAudioData()
        let document = AIFFContainer(
            channelsCount: self.metadata.streamInfo.channelsCount,
            sampleSize: self.metadata.streamInfo.bitsPerSample,
            sampleRate: Double(self.metadata.streamInfo.sampleRate),
            soundData: data
        )
        try document.write(to: url)
    }
    
}

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
            let frameBuffer = buffer.baseAddress! + accumulativeWidth
            
            frame.write(to: frameBuffer)
    
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

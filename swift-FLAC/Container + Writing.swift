//
//  Container + Writing.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

//import AVFoundation
//
//
//extension FLACContainer {
//    
//    public func write(to url: URL, fileType outputFileType: AVFileType) async throws {
//        guard let firstFrame = self.frames.first else {
//            throw WriteError.noAvailableFrame
//        }
//        
//        let sampleRate = self.metadata.streamInfo.sampleRate
//        let channels = AVAudioChannelCount(firstFrame.header.channelAssignment.channelCount)
//        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: channels) else { throw WriteError.invalidFLACFormat }
//        
//        guard let assetWriter = try? AVAssetWriter(outputURL: url, fileType: outputFileType) else {
//            throw WriteError.cannotCreateWriter
//        }
//        
//        let assetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [
//            AVFormatIDKey: outputFileType.rawValue,
//            AVNumberOfChannelsKey: channels,
//            AVSampleRateKey: sampleRate
//        ])
//        
//        if assetWriter.canAdd(assetWriterInput) {
//            assetWriter.add(assetWriterInput)
//        } else {
//            throw WriteError.cannotAddWriter
//        }
//        
//        
//        assetWriter.startWriting()
//        assetWriter.startSession(atSourceTime: .zero)
//        
//        
//        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(self.frames.count)) else { throw WriteError.cannotCreatePCMBuffer }
//        buffer.frameLength = AVAudioFrameCount(self.frames.count)
//        
//        
//        guard let channels = buffer.int32ChannelData else {
//            throw WriteError.cannotWriteFrame
//        }
//        
//        var dataIndex: [Int] = [Int](repeating: 0, count: firstFrame.header.channelAssignment.channelCount)
//        var index = 0
//        while index < self.frames.count {
//            for (channelIndex, subframe) in self.frames[index].subframes.enumerated() {
//                switch subframe.payload {
//                case .verbatim(let verbatim):
//                    verbatim.data.withUnsafeBytes { buffer in
//                        let buffer = buffer.bindMemory(to: Int32.self)
//                        
//                        var ii = 0
//                        while ii < buffer.count {
//                            channels[channelIndex][dataIndex[channelIndex]] = buffer[ii]
//                            
//                            ii &+= 1
//                        }
//                        
//                        dataIndex[channelIndex] &+= buffer.count
//                    }
//                default:
//                    fatalError("Not implemented")
//                }
//            }
//            
//            index &+= 1
//        }
//        
//        assetWriterInput.append(buffer)
//        
//        
//        assetWriterInput.markAsFinished()
//        await assetWriter.finishWriting()
//    }
//    
//    public enum WriteError: Error {
//        case noAvailableFrame
//        case invalidFLACFormat
//        case cannotCreateWriter
//        case cannotAddWriter
//        case cannotCreatePCMBuffer
//        case cannotWriteFrame
//    }
//    
//}

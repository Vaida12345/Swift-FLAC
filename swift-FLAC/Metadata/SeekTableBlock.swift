//
//  SeekTableBlock.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Metadata {
    
    /// A block for storing seek points.
    ///
    /// It is possible to seek to any given sample in a FLAC stream without a seek table, but the delay can be unpredictable since the bitrate may vary widely within a stream. By adding seek points to a stream, this delay can be significantly reduced. Each seek point takes 18 bytes, so 1% resolution within a stream adds less than 2k. The table can have any number of ``SeekTableBlock/SeekPoint``. There is also a special 'placeholder' ``SeekTableBlock/SeekPoint`` which will be ignored by decoders but which can be used to reserve space for future seek point insertion.
    public struct SeekTableBlock: DetailedStringConvertible {
        
        /// Seek points within a table must be sorted in ascending order by sample number.
        public let points: [SeekPoint]
        
        init(data: Data) throws {
            var handler = BitsDecoder(data)
            
            let count = data.count / 18
            var points: [SeekPoint] = []
            points.reserveCapacity(count)
            
            for _ in 1...count {
                try points.append(SeekPoint(handler: &handler))
            }
            
            self.points = points
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Metadata.SeekTableBlock>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.sequence(for: \.points)
            }
        }
        
        
        public struct SeekPoint: DetailedStringConvertible {
            
            /// Sample number of first sample in the target frame
            public let sampleNumber: Int
            
            /// Offset (in bytes) from the first byte of the first frame header to the first byte of the target frame's header.
            public let offset: Int
            
            /// Number of samples in the target frame.
            public let length: Int
            
            
            init(handler: inout BitsDecoder) throws {
                self.sampleNumber = try handler.decodeInt(encoding: .unsigned(bits: 64))
                self.offset = try handler.decodeInt(encoding: .unsigned(bits: 64))
                self.length = try handler.decodeInt(encoding: .unsigned(bits: 16))
            }
            
            public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Metadata.SeekTableBlock.SeekPoint>) -> any DescriptionBlockProtocol {
                descriptor.container {
                    descriptor.value(for: \.sampleNumber)
                    descriptor.value(for: \.offset)
                    descriptor.value(for: \.length)
                }
            }
            
        }
        
    }
    
}

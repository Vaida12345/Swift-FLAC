//
//  Frame.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription


extension FLACContainer {
    
    public struct Frame: CustomDetailedStringConvertible {
        
        public let header: Header
        
        /// One subframe per channel.
        public let subframes: [Subframe]
        
        /// CRC-16 (polynomial = x^16 + x^15 + x^2 + x^0, initialized with 0) of everything before the crc, back to and including the frame header sync code
        public let checksum: Int
        
        
        init(handler: inout BitsDecoder, streamInfo: FLACContainer.Metadata.StreamInfoBlock) throws {
            let header = try Header(handler: &handler, streamInfo: streamInfo)
            self.header = header
            let channelCount = self.header.channelAssignment.channelCount
            self.subframes = try (0..<channelCount).map({ _ in try Subframe(handler: &handler, header: header) })
            
            if !handler.bitIndex.isMultiple(of: 8) {
                guard try handler.decodeInteger(bitsCount: 8 - handler.bitIndex % 8) == 0 else {
                    throw DecodeError.invalidPadding
                }
            }
            assert(handler.bitIndex.isMultiple(of: 8))
            
            self.checksum = try handler.decodeInteger(bitsCount: 16)
        }
        
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.header)
                descriptor.sequence(for: \.subframes)
            }
        }
        
        
        public enum DecodeError: Error {
            case invalidPadding
        }
        
    }
    
}

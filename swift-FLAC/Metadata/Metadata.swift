//
//  Metadata.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription


extension FLACContainer {
    
    /// A collection of flac metadata.
    ///
    /// - Note: Paddings are not decoded.
    public struct Metadata: CustomDetailedStringConvertible {
        
        public let streamInfo: StreamInfoBlock
        
        public internal(set) var application: [ApplicationBlock] = []
        
        public internal(set) var seekTable: SeekTableBlock? = nil
        
        public internal(set) var vorbisComment: VorbisCommentBlock? = nil
        
        
        public init(streamInfo: StreamInfoBlock) {
            self.streamInfo = streamInfo
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Metadata>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.streamInfo)
                descriptor.sequence(for: \.application, hideEmptySequence: true)
                descriptor.optional(for: \.seekTable)
                descriptor.optional(for: \.vorbisComment)
            }
        }
        
    }
    
}

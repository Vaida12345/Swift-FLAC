//
//  VorbisCommentBlock.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Metadata {
    
    /// Aka FLAC tags, this block is for storing a list of human-readable name/value pairs.
    ///
    /// It is an implementation of the [Vorbis comment specification](https://xiph.org/vorbis/doc/v-comment.html) (without the framing bit). This is the only officially supported tagging mechanism in FLAC. In some external documentation, Vorbis comments are called *FLAC tags* to lessen confusion.
    ///
    /// The ``VorbisCommentBlock/tags`` encodes all key-value pairs defined in this block. The other properties, excluding ``VorbisCommentBlock/vendor``, are shorthands for lookups in this dictionary.
    ///
    /// - Tip: The properties (keys) can be lookup by name at runtime, [read more on swift.org](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes#dynamicMemberLookup).
    ///
    /// ## Topics
    /// ### Stored Properties
    ///
    /// - ``vendor``
    /// - ``tags``
    @dynamicMemberLookup
    public struct VorbisCommentBlock: DetailedStringConvertible {
        
        /// The encoder used.
        public let vendor: String
        
        /// Every tag defined in this block.
        public let tags: [String: String]
        
        /// Track/Work name
        public var title: String? {
            tags["TITLE"]
        }
        
        /// The version field may be used to differentiate multiple versions of the same track title in a single collection. (e.g. remix info)
        public var version: String? {
            tags["VERSION"]
        }
        
        /// The collection name to which this track belongs
        public var album: String? {
            tags["ALBUM"]
        }
        
        /// The track number of this piece if part of a specific larger collection or album
        public var trackNumber: String? {
            tags["TRACKNUMBER"]
        }
        
        /// The artist generally considered responsible for the work.
        ///
        /// In popular music this is usually the performing band or singer. For classical music it would be the composer. For an audio book it would be the author of the original text.
        public var artist: String? {
            tags["ARTIST"]
        }
        
        /// The artist(s) who performed the work.
        ///
        /// In classical music this would be the conductor, orchestra, soloists. In an audio book it would be the actor who did the reading. In popular music this is typically the same as the ARTIST and is omitted.
        public var performer: String? {
            tags["PERFORMER"]
        }
        
        /// Copyright attribution, e.g., '2001 Nobody's Band' or '1999 Jack Moffitt'
        public var copyright: String? {
            tags["COPYRIGHT"]
        }
        
        /// License information, for example, 'All Rights Reserved', 'Any Use Permitted', a URL to a license such as a Creative Commons license (e.g. "creativecommons.org/licenses/by/4.0/"), or similar.
        public var license: String? {
            tags["LICENSE"]
        }
        
        /// Name of the organization producing the track (i.e. the 'record label')
        public var organization: String? {
            tags["ORGANIZATION"]
        }
        
        /// A short text description of the contents
        public var description: String? {
            tags["DESCRIPTION"]
        }
        
        /// A short text indication of music genre
        public var genre: String? {
            tags["GENRE"]
        }
        
        /// Date the track was recorded
        public var date: String? {
            tags["DATE"]
        }
        
        /// Location where track was recorded
        public var location: String? {
            tags["LOCATION"]
        }
        
        /// Contact information for the creators or distributors of the track.
        ///
        /// This could be a URL, an email address, the physical address of the producing label.
        public var contact: String? {
            tags["CONTACT"]
        }
        
        /// ISRC number for the track; see the [ISRC intro page](https://isrc.ifpi.org/en/) for more information on ISRC numbers.
        public var ISRC: String? {
            tags["ISRC"]
        }
        
        
        /// Common property added by the `Swift-FLAC` package.
        public var albumArtist: String? {
            tags["ALBUMARTIST"]
        }
        
        /// Common property added by the `Swift-FLAC` package.
        public var composer: String? {
            tags["COMPOSER"]
        }
        
        /// Common property added by the `Swift-FLAC` package.
        public var discNumber: String? {
            tags["DISCNUMBER"]
        }
        
        /// Common property added by the `Swift-FLAC` package.
        public var comment: String? {
            tags["COMMENT"]
        }
        
        
        init(data: Data) throws {
            var handler = BitsDecoder(data)
            let vendorLength = try handler.decodeInt(encoding: .unsigned(bits: 32, endianness: .littleEndian))
            self.vendor = try handler.decodeString(bytesCount: vendorLength, encoding: .utf8)
            
            
            var tags: [String: String] = [:]
            
            let userCommentListLength = try handler.decodeInt(encoding: .unsigned(bits: 32, endianness: .littleEndian))
            for _ in 1...userCommentListLength {
                let length = try handler.decodeInt(encoding: .unsigned(bits: 32, endianness: .littleEndian))
                guard let content = try? handler.decodeString(bytesCount: length, encoding: .utf8) else { continue }
                
                guard let separator = content.firstIndex(of: "=") else { continue }
                let key = String(content[..<separator])
                let value = String(content[content.index(after: separator)...])
                guard !value.allSatisfy({ $0.isWhitespace }) else { continue }
                
                tags[key] = value
            }
            
            self.tags = tags
        }
        
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Metadata.VorbisCommentBlock>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.vendor)
                
                for (key, value) in tags {
                    descriptor.value(key, of: value)
                }
            }
        }
        
        public subscript(dynamicMember dynamicMember: String) -> String? {
            self.tags[dynamicMember]
        }
        
    }
    
}

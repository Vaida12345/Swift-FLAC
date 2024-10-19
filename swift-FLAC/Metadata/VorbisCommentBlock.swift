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
    
    /// This block is for storing a list of human-readable name/value pairs.
    ///
    /// Values are encoded using UTF-8. It is an implementation of the [Vorbis comment specification](https://xiph.org/vorbis/doc/v-comment.html) (without the framing bit). This is the only officially supported tagging mechanism in FLAC. There may be only one `VORBIS_COMMENT` block in a stream. In some external documentation, Vorbis comments are called FLAC tags to lessen confusion.
    ///
    /// Also known as FLAC tags, the contents of a vorbis comment packet as specified here (without the framing bit). Note that the vorbis comment spec allows for on the order of 2 ^ 64 bytes of data where as the FLAC metadata block is limited to 2 ^ 24 bytes. Given the stated purpose of vorbis comments, i.e. human-readable textual information, this limit is unlikely to be restrictive. Also note that the 32-bit field lengths are little-endian coded according to the vorbis spec, as opposed to the usual big-endian coding of fixed-length integers in the rest of FLAC.
    public struct VorbisCommentBlock: CustomDetailedStringConvertible {
        
        public let vendor: String
        
        /// Track/Work name
        public private(set) var title: String?
        
        /// The version field may be used to differentiate multiple versions of the same track title in a single collection. (e.g. remix info)
        public private(set) var version: String?
        
        /// The collection name to which this track belongs
        public private(set) var album: String?
        
        /// The track number of this piece if part of a specific larger collection or album
        public private(set) var trackNumber: String?
        
        /// The artist generally considered responsible for the work.
        ///
        /// In popular music this is usually the performing band or singer. For classical music it would be the composer. For an audio book it would be the author of the original text.
        public private(set) var artist: String?
        
        /// The artist(s) who performed the work.
        ///
        /// In classical music this would be the conductor, orchestra, soloists. In an audio book it would be the actor who did the reading. In popular music this is typically the same as the ARTIST and is omitted.
        public private(set) var performer: String?
        
        /// Copyright attribution, e.g., '2001 Nobody's Band' or '1999 Jack Moffitt'
        public private(set) var copyright: String?
        
        /// License information, for example, 'All Rights Reserved', 'Any Use Permitted', a URL to a license such as a Creative Commons license (e.g. "creativecommons.org/licenses/by/4.0/"), or similar.
        public private(set) var license: String?
        
        /// Name of the organization producing the track (i.e. the 'record label')
        public private(set) var organization: String?
        
        /// A short text description of the contents
        public private(set) var description: String?
        
        /// A short text indication of music genre
        public private(set) var genre: String?
        
        /// Date the track was recorded
        public private(set) var date: String?
        
        /// Location where track was recorded
        public private(set) var location: String?
        
        /// Contact information for the creators or distributors of the track.
        ///
        /// This could be a URL, an email address, the physical address of the producing label.
        public private(set) var contact: String?
        
        /// ISRC number for the track; see the [ISRC intro page](https://isrc.ifpi.org/en/) for more information on ISRC numbers.
        public private(set) var ISRC: String?
        
        
        /// Common property added by the `Swift-FLAC` package.
        public private(set) var albumArtist: String?
        
        /// Common property added by the `Swift-FLAC` package.
        public private(set) var composer: String?
        
        /// Common property added by the `Swift-FLAC` package.
        public private(set) var discNumber: String?
        
        /// Common property added by the `Swift-FLAC` package.
        public private(set) var comment: String?
        
        /// The additional information not covered by the predefined properties.
        public let additionalInformation: [String: String]
        
        
        init(data: Data) throws {
            var handler = BytesDecoder(data)
            let vendorLength = try handler.decodeInteger(bytesCount: 32 / 8, isBigEndian: false)
            self.vendor = try handler.decodeString(bytesCount: vendorLength, encoding: .utf8)
            
            
            var additionalInformation: [String: String] = [:]
            
            let userCommentListLength = try handler.decodeInteger(bytesCount: 32 / 8, isBigEndian: false)
            for _ in 1...userCommentListLength {
                let length = try handler.decodeInteger(bytesCount: 32 / 8, isBigEndian: false)
                guard let content = try? handler.decodeString(bytesCount: length, encoding: .utf8) else { continue }
                
                guard let separator = content.firstIndex(of: "=") else { continue }
                let key = String(content[..<separator])
                let value = String(content[content.index(after: separator)...])
                guard !value.allSatisfy({ $0.isWhitespace }) else { continue }
                
                switch key.uppercased() {
                case "TITLE": self.title = value
                case "VERSION": self.version = value
                case "ALBUM": self.album = value
                case "TRACKNUMBER": self.trackNumber = value
                case "ARTIST": self.artist = value
                case "PERFORMER": self.performer = value
                case "COPYRIGHT": self.copyright = value
                case "LICENSE": self.license = value
                case "ORGANIZATION": self.organization = value
                case "DESCRIPTION": self.description = value
                case "GENRE": self.genre = value
                case "DATE": self.date = value
                case "LOCATION": self.location = value
                case "CONTACT": self.contact = value
                case "ISRC": self.ISRC = value
                case "ALBUMARTIST": self.albumArtist = value
                case "COMPOSER": self.composer = value
                case "DISCNUMBER": self.discNumber = value
                case "COMMENT": self.comment = value
                default: additionalInformation[key] = value
                }
            }
            
            self.additionalInformation = additionalInformation
        }
        
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Metadata.VorbisCommentBlock>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.vendor)
                descriptor.optional(for: \.title)
                descriptor.optional(for: \.version)
                descriptor.optional(for: \.album)
                descriptor.optional(for: \.albumArtist)
                descriptor.optional(for: \.trackNumber)
                descriptor.optional(for: \.artist)
                descriptor.optional(for: \.performer)
                descriptor.optional(for: \.copyright)
                descriptor.optional(for: \.license)
                descriptor.optional(for: \.organization)
                descriptor.optional(for: \.description)
                descriptor.optional(for: \.genre)
                descriptor.optional(for: \.date)
                descriptor.optional(for: \.location)
                descriptor.optional(for: \.contact)
                descriptor.optional(for: \.ISRC)
                descriptor.optional(for: \.albumArtist)
                descriptor.optional(for: \.composer)
                descriptor.optional(for: \.discNumber)
                descriptor.optional(for: \.comment)
                
                for (key, value) in additionalInformation {
                    descriptor.value(key, of: value)
                }
            }
        }
        
    }
    
}

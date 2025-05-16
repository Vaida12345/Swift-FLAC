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
    ///
    /// ## Topics
    /// ### The Blocks
    /// - ``FLACContainer/Metadata-swift.struct/streamInfo``
    /// - ``FLACContainer/Metadata-swift.struct/application``
    /// - ``FLACContainer/Metadata-swift.struct/seekTable``
    /// - ``FLACContainer/Metadata-swift.struct/vorbisComment``
    /// - ``FLACContainer/Metadata-swift.struct/cueSheet``
    /// - ``FLACContainer/Metadata-swift.struct/pictures``
    /// - ``FLACContainer/Metadata-swift.struct/rawFields``
    public struct Metadata: DetailedStringConvertible {
        
        /// This block has information about the whole stream, like sample rate, number of channels, total number of samples, etc.
        ///
        /// It must be present as the first metadata block in the stream. Other metadata blocks may follow, and ones that the decoder doesn't understand, it will skip.
        ///
        /// - SeeAlso: ``StreamInfoBlock``
        public let streamInfo: StreamInfoBlock
        
        /// This block is for use by third-party applications.
        ///
        /// The ``ApplicationBlock/id`` is granted upon request to an application by the FLAC maintainers. The remainder is of the block (``ApplicationBlock/data``) is defined by the registered application. Visit the [registration page](https://xiph.org/flac/id.html) if you would like to register an ID for your application with FLAC.
        ///
        /// - SeeAlso: ``ApplicationBlock``
        public internal(set) var application: [ApplicationBlock] = []
        
        /// A block for storing seek points.
        ///
        /// It is possible to seek to any given sample in a FLAC stream without a seek table, but the delay can be unpredictable since the bitrate may vary widely within a stream. By adding seek points to a stream, this delay can be significantly reduced. Each seek point takes 18 bytes, so 1% resolution within a stream adds less than 2k. The table can have any number of ``SeekTableBlock/SeekPoint``. There is also a special 'placeholder' ``SeekTableBlock/SeekPoint`` which will be ignored by decoders but which can be used to reserve space for future seek point insertion.
        /// 
        /// - SeeAlso: ``SeekTableBlock``
        public internal(set) var seekTable: SeekTableBlock? = nil
        
        /// Aka FLAC tags, this block is for storing a list of human-readable name/value pairs.
        ///
        /// It is an implementation of the [Vorbis comment specification](https://xiph.org/vorbis/doc/v-comment.html) (without the framing bit). This is the only officially supported tagging mechanism in FLAC. In some external documentation, Vorbis comments are called *FLAC tags* to lessen confusion.
        ///
        /// The ``VorbisCommentBlock/tags`` encodes all key-value pairs defined in this block. The other properties, excluding ``VorbisCommentBlock/vendor``, are shorthands for lookups in this dictionary.
        ///
        /// - Tip: The properties (keys) can be lookup by name at runtime, [read more on swift.org](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes#dynamicMemberLookup).
        /// 
        /// - SeeAlso: ``VorbisCommentBlock``
        public internal(set) var vorbisComment: VorbisCommentBlock? = nil
        
        /// This block is for storing various information that can be used in a cue sheet.
        ///
        /// It supports track and index points, compatible with Red Book CD digital audio discs, as well as other CD-DA metadata such as media catalog number and track ISRCs. The ``CueSheetBlock`` is especially useful for backing up CD-DA discs, but it can be used as a general purpose cueing mechanism for playback.
        ///
        /// - SeeAlso: ``CueSheetBlock``
        public internal(set) var cueSheet: CueSheetBlock? = nil
        
        /// This block is for storing pictures associated with the file, most commonly cover art from CDs.
        ///
        /// The picture format is similar to the APIC frame in [ID3v2](https://id3.org/id3v2.3.0). The ``PictureBlock`` has a type, ``PictureBlock/MIMEType``, and UTF-8 description like [ID3v2](https://id3.org/id3v2.3.0), and supports external linking via URL (though this is discouraged). The differences are that there is no uniqueness constraint on the ``PictureBlock/description`` field, and the ``PictureBlock/MIMEType`` is mandatory. The ``PictureBlock`` also includes the resolution (``PictureBlock/width``, ``PictureBlock/height``), ``PictureBlock/colorDepth``, and ``PictureBlock/paletteSize`` so that the client can search for a suitable picture without having to scan them all.
        ///
        /// - SeeAlso: ``PictureBlock``
        public internal(set) var pictures: [PictureBlock] = []
        
        /// Un-decoded raw fields.
        ///
        /// These are the fields that the decoder doesn't understand.
        ///
        /// - Note: The ``RawMetadata/blockType-swift.property`` is usually `nil`.
        ///
        /// - SeeAlso: ``RawMetadata``
        public internal(set) var rawFields: [RawMetadata] = []
        
        
        init(streamInfo: StreamInfoBlock) {
            self.streamInfo = streamInfo
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Metadata>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.streamInfo)
                descriptor.sequence(for: \.application)
                    .hideEmptySequence()
                descriptor.optional(for: \.seekTable)
                descriptor.optional(for: \.vorbisComment)
                descriptor.optional(for: \.cueSheet)
                descriptor.sequence(for: \.pictures)
                    .hideEmptySequence()
                descriptor.sequence(for: \.rawFields)
                    .hideEmptySequence()
            }
        }
        
    }
    
}

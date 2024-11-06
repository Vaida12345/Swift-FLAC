//
//  CueSheetBlock.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Metadata {
    
    /// This block is for storing various information that can be used in a cue sheet.
    ///
    /// It supports track and index points, compatible with Red Book CD digital audio discs, as well as other CD-DA metadata such as media catalog number and track ISRCs. The ``CueSheetBlock`` is especially useful for backing up CD-DA discs, but it can be used as a general purpose cueing mechanism for playback.
    public struct CueSheetBlock {
        
        /// Media catalog number, in ASCII printable characters 0x20-0x7e.
        ///
        /// In general, the media catalog number may be 0 to 128 bytes long; any unused characters should be right-padded with NUL characters. For CD-DA, this is a thirteen digit number, followed by 115 NUL bytes.
        public let mediaCatalogNumber: String
        
        /// The number of lead-in samples.
        ///
        /// This field has meaning only for CD-DA cuesheets; for other uses it should be 0. For CD-DA, the lead-in is the TRACK 00 area where the table of contents is stored; more precisely, it is the number of samples from the first sample of the media to the first sample of the first index point of the first track. According to the Red Book, the lead-in must be silence and CD grabbing software does not usually store it; additionally, the lead-in must be at least two seconds but may be longer. For these reasons the lead-in length is stored here so that the absolute position of the first track can be computed. Note that the lead-in stored here is the number of samples up to the first index point of the first track, not necessarily to INDEX 01 of the first track; even the first track may have INDEX 00 data.
        public let leadInSamplesCount: Int
        
        public let isCompactDisc: Bool
        
        /// One or more tracks.
        ///
        /// A ``CueSheetBlock`` is required to have a lead-out track; it is always the last track in the ``CueSheetBlock``. For CD-DA, the lead-out track number must be 170 as specified by the Red Book, otherwise is must be 255.
        public let tracks: [Track]
        
        
        init(data: Data) throws {
            var handler = BitsDecoder(data)
            
            self.mediaCatalogNumber = try handler.decodeString(bytesCount: 128, encoding: .ascii)
            self.leadInSamplesCount = try handler.decodeInt(encoding: .unsigned(bits: 64))
            self.isCompactDisc = try handler.decodeBool()
            
            // reserved space
            handler.seek(by: 7 + 258 * 8)
            
            let tracksCount = try handler.decodeInt(encoding: .unsigned(bits: 8))
            
            var tracks: [Track] = []
            tracks.reserveCapacity(tracksCount)
            for _ in 0..<tracksCount {
                try tracks.append(Track(handler: &handler))
            }
            
            self.tracks = tracks
        }
        
        
        public struct Track {
            
            /// Track offset in samples, relative to the beginning of the FLAC audio stream.
            ///
            /// It is the offset to the first index point of the track. (Note how this differs from CD-DA, where the track's offset in the TOC is that of the track's INDEX 01 even if there is an INDEX 00.) For CD-DA, the offset must be evenly divisible by 588 samples (588 samples = 44100 samples/sec * 1/75th of a sec).
            public let offset: Int
            
            /// Track number. A track number of 0 is not allowed to avoid conflicting with the CD-DA spec, which reserves this for the lead-in. For CD-DA the number must be 1-99, or 170 for the lead-out; for non-CD-DA, the track number must for 255 for the lead-out. It is not required but encouraged to start with track 1 and increase sequentially. Track numbers must be unique within a CUESHEET.
            public let trackNumber: Int
            
            /// Track ISRC.
            ///
            /// This is a 12-digit alphanumeric code; see [here](http://isrc.ifpi.org/) and [here](http://www.disctronics.co.uk/technology/cdaudio/cdaud_isrc.htm). A value of 12 ASCII NUL characters may be used to denote absence of an ISRC.
            public let ISRC: String
            
            /// The track type: 0 for audio, 1 for non-audio. This corresponds to the CD-DA Q-channel control bit 3.
            public let trackIsAudio: Bool
            
            /// The pre-emphasis flag: 0 for no pre-emphasis, 1 for pre-emphasis.
            ///
            /// This corresponds to the CD-DA Q-channel control bit 5; see [here](http://www.chipchapin.com/CDMedia/cdda9.php3).
            public let isPreEmphasis: Bool
            
            public let indexPoints: [IndexPoint]
            
            
            init(handler: inout BitsDecoder) throws {
                self.offset = try handler.decodeInt(encoding: .unsigned(bits: 64))
                self.trackNumber = try handler.decodeInt(encoding: .unsigned(bits: 8))
                self.ISRC = try handler.decodeString(bytesCount: 12, encoding: .ascii)
                self.trackIsAudio = try handler.decodeBool()
                self.isPreEmphasis = try handler.decodeBool()
                
                // reserved space
                handler.seek(by: 6 + 13 * 8)
                
                let trackIndexPointsCount = try handler.decodeInt(encoding: .unsigned(bits: 8))
                
                var indexPoints: [IndexPoint] = []
                indexPoints.reserveCapacity(trackIndexPointsCount)
                
                for _ in 0..<trackIndexPointsCount {
                    try indexPoints.append(IndexPoint(handler: &handler))
                }
                
                self.indexPoints = indexPoints
            }
            
            
            public struct IndexPoint {
                
                /// Offset in samples, relative to the track offset, of the index point.
                ///
                /// For CD-DA, the offset must be evenly divisible by 588 samples (588 samples = 44100 samples/sec * 1/75th of a sec). Note that the offset is from the beginning of the track, not the beginning of the audio data.
                public let offset: Int
                
                /// The index point number. For CD-DA, an index number of 0 corresponds to the track pre-gap. The first index in a track must have a number of 0 or 1, and subsequently, index numbers must increase by 1. Index numbers must be unique within a track.
                public let indexPointNumber: Int
                
                
                init(handler: inout BitsDecoder) throws {
                    self.offset = try handler.decodeInt(encoding: .unsigned(bits: 64))
                    self.indexPointNumber = try handler.decodeInt(encoding: .unsigned(bits: 8))
                    
                    // reserved space
                    handler.seek(by: 3 * 8)
                }
                
            }
            
        }
        
    }
    
}

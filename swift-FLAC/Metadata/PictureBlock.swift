//
//  PictureBlock.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Metadata {
    
    /// This block is for storing pictures associated with the file, most commonly cover art from CDs.
    ///
    /// There may be more than one PICTURE block in a file. The picture format is similar to the APIC frame in ID3v2. The PICTURE block has a type, MIME type, and UTF-8 description like ID3v2, and supports external linking via URL (though this is discouraged). The differences are that there is no uniqueness constraint on the description field, and the MIME type is mandatory. The FLAC PICTURE block also includes the resolution, color depth, and palette size so that the client can search for a suitable picture without having to scan them all.
    public struct PictureBlock: CustomDetailedStringConvertible {
        
        /// The picture type according to the ID3v2 APIC frame:
        public let pictureType: PictureType
        
        /// The MIME type string, in printable ASCII characters 0x20-0x7e. The MIME type may also be --> to signify that the data part is a URL of the picture instead of the picture data itself.
        public let MIMEType: String
        
        /// The description of the picture, in UTF-8.
        public let description: String
        
        /// The width of the picture in pixels.
        public let width: Int
        
        /// The height of the picture in pixels.
        public let height: Int
        
        /// The color depth of the picture in bits-per-pixel.
        public let colorDepth: Int
        
        /// For indexed-color pictures (e.g. GIF), the number of colors used, or 0 for non-indexed pictures.
        public let colorsUsedCount: Int
        
        /// The binary picture data.
        public let data: Data
        
        
        init(data: Data) throws {
            var handler = BitsDecoder(data)
            
            guard let pictureType = try PictureType(rawValue: handler.decode(bitsCount: 32)) else {
                throw DecodeError.invalidPictureType
            }
            self.pictureType = pictureType
            
            let MIMELength = try handler.decodeInt(encoding: .unsigned(bits: 32))
            self.MIMEType = try handler.decodeString(bytesCount: MIMELength, encoding: .ascii)
            
            let descriptionLength = try handler.decodeInt(encoding: .unsigned(bits: 32))
            self.description = try handler.decodeString(bytesCount: descriptionLength, encoding: .utf8)
            
            self.width = try handler.decodeInt(encoding: .unsigned(bits: 32))
            self.height = try handler.decodeInt(encoding: .unsigned(bits: 32))
            self.colorDepth = try handler.decodeInt(encoding: .unsigned(bits: 32))
            self.colorsUsedCount = try handler.decodeInt(encoding: .unsigned(bits: 32))
            
            let dataLength = try handler.decodeInt(encoding: .unsigned(bits: 32))
            self.data = try handler.decodeData(bytesCount: dataLength)
        }
        
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Metadata.PictureBlock>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.pictureType)
                descriptor.value(for: \.MIMEType)
                descriptor.value(for: \.description)
                descriptor.value(for: \.width)
                descriptor.value(for: \.height)
                descriptor.value(for: \.colorDepth)
                descriptor.value(for: \.colorsUsedCount)
            }
        }
        
        public enum PictureType: UInt32 {
            case other
            /// 32x32 pixels 'file icon' (PNG only)
            case fileIcon
            /// Other file icon
            case otherFileIcon
            case frontCover
            case backCover
            case leafletPage
            case media
            /// Lead artist/lead performer/soloist
            case leadPerformer
            /// Artist/performer
            case performer
            case conductor
            case lyricist
            case recordingLocation
            case duringRecording
            case duringPerformance
            case videoScreenCapture
            case brightColoredFish
            case illustration
            case artistLogotype
            case studioLogotype
        }
        
        public enum DecodeError: Error {
            case invalidPictureType
        }
        
    }
    
}

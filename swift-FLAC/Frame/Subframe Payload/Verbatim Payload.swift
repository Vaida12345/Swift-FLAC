//
//  Verbatim Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct Verbatim: CustomStringConvertible {
        
        public let data: Data
        
        public var description: String {
            data.description
        }
        
        init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subheader: FLACContainer.Frame.Subframe.Header) throws {
            assert(header.bitsPerSample * header.blockSize % 8 == 0)
            self.data = try handler.decodeData(bytesCount: header.bitsPerSample * header.blockSize / 8)
        }
        
    }
    
}

//
//  Constant Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct Constant: CustomStringConvertible {
        
        public let sample: Int
        
        public var description: String {
            sample.description
        }
        
        init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subheader: FLACContainer.Frame.Subframe.Header) throws {
            assert(header.bitsPerSample % 8 == 0)
            self.sample = try handler.decodeInt(encoding: .signed(bits: header.bitsPerSample))
        }
        
    }
    
}

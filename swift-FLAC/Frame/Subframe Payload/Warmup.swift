//
//  Warmup.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/21/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct Warmup: CustomStringConvertible {
        
        public let data: [Int]
        
        public var description: String {
            data.description
        }
        
        init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, index: Int, order: Int) throws {
            let isSideChannel = (index == 1 && (header.channelAssignment == .midSideStereo || header.channelAssignment == .leftSideStereo)) || (index == 0 && header.channelAssignment == .rightSideStereo)
            self.data = try (0..<order).map { _ in
                try handler.decodeInt(encoding: .signed(bits: header.bitsPerSample + (isSideChannel ? 1 : 0)))
            }
        }
        
    }
    
}

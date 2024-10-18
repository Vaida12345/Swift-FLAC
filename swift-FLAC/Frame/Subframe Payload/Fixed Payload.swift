//
//  Fixed Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct Fixed {
        
        public let data: Data
        
        public let residual: Residual
        
        
        init(
            handler: inout BitsDecoder,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header,
            predicatorOrder: Int
        ) throws {
            assert(header.bitsPerSample * predicatorOrder % 8 == 0)
            self.data = try handler.decodeData(bytesCount: header.bitsPerSample * predicatorOrder / 8)
            self.residual = try Residual(handler: &handler, header: header, subheader: subheader, predicatorOrder: predicatorOrder)
        }
        
        public enum DecodeError: Error {
            case typeMismatch
        }
        
    }
    
}

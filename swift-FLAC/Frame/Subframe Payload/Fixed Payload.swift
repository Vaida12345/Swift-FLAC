//
//  Fixed Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct Fixed: CustomDetailedStringConvertible {
        
        /// Unencoded warm-up samples
        public let warmup: Warmup
        
        public let residual: Residual
        
        
        init(
            handler: inout BitsDecoder,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header,
            predicatorOrder: Int,
            index: Int
        ) throws {
            assert(header.bitsPerSample * predicatorOrder % 8 == 0)
            self.warmup = try Warmup(handler: &handler, header: header, index: index, order: predicatorOrder)
            self.residual = try Residual(handler: &handler, header: header, subheader: subheader, predicatorOrder: predicatorOrder)
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Subframe.Payload.Fixed>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.warmup)
                descriptor.value(for: \.residual)
            }
        }
        
        public enum DecodeError: Error {
            case typeMismatch
        }
        
    }
    
}

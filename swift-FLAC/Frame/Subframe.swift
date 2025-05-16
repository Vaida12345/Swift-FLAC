//
//  Subframe.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame {
    
    /// A subframe header plus one or more encoded samples from a given channel. All subframes within a frame will contain the same number of samples.
    public struct Subframe: DetailedStringConvertible {
        
        public let header: Header
        
        public let payload: Payload
        
        init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subframeIndex: Int) throws {
            let subheader = try Header(handler: &handler)
            self.header = subheader
            
            switch subheader.type {
            case .constant:
                self.payload = try .constant(Payload.Constant(handler: &handler, header: header, subheader: subheader, channelIndex: subframeIndex))
                
            case .fixed(let order):
                self.payload = try .fixed(Payload.Fixed(handler: &handler, header: header, subheader: subheader, predicatorOrder: order, index: subframeIndex))
                
            case .lpc(let order):
                self.payload = try .lpc(Payload.LPC(handler: &handler, header: header, subheader: subheader, order: order, index: subframeIndex))
                
            case .verbatim:
                self.payload = .verbatim(try Payload.Verbatim(handler: &handler, header: header, subheader: subheader))
                
            case .reserved(let bits):
                throw DecodeError.reservedType(bits: bits)
            }
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Subframe>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.header)
                descriptor.value(for: \.payload)
            }
        }
        
        public enum DecodeError: Error {
            case reservedType(bits: Int)
        }
        
    }
    
}

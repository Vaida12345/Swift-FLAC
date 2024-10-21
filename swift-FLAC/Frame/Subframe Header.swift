//
//  Subframe Header.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame.Subframe {
    
    public struct Header: CustomDetailedStringConvertible {
        
        let type: SubframeType
        
        ///  k wasted bits-per-sample in source subblock.
        let wastedBitsPerSample: Int
        
        init(handler: inout BitsDecoder) throws {
            guard try handler.decodeBool() == false else { throw DecodeError.missingPadding }
            
            let rawType = try handler.decodeInt(encoding: .unsigned(bits: 6))
            switch rawType {
            case 0b000000: self.type = .constant
            case 0b000001: self.type = .verbatim
            default:
                if rawType >> 1 == 1 || rawType >> 2 == 1 {
                    self.type = .reserved(bits: rawType)
                } else if rawType >> 3 == 1 {
                    let carriedBits = rawType & 0b000111
                    if carriedBits <= 4 {
                        self.type = .fixed(order: carriedBits)
                    } else {
                        self.type = .reserved(bits: rawType)
                    }
                } else if rawType >> 4 == 1 {
                    self.type = .reserved(bits: rawType)
                } else if rawType >> 5 == 1 {
                    self.type = .lpc(order: (rawType & 0b011111) + 1)
                } else {
                    fatalError() // will never reach
                }
            }
            
            if try handler.decodeBool() == true {
                self.wastedBitsPerSample = try handler.decodeInt(encoding: .unary) + 1
            } else {
                self.wastedBitsPerSample = 0
            }
            
//            print(self)
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Subframe.Header>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.type)
                descriptor.value(for: \.wastedBitsPerSample)
            }
        }
        
        public enum SubframeType {
            case constant
            case verbatim
            case fixed(order: Int)
            case lpc(order: Int)
            case reserved(bits: Int)
        }
        
        public enum DecodeError: Error {
            case missingPadding
        }
        
    }
    
}

//
//  LPC Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct LPC {
        
        public let unencodedWarmupSamples: Data
        
        /// Quantized linear predictor coefficients' precision in bits
        public let linearPredictorCoefficientsPrecisions: Int
        
        /// Quantized linear predictor coefficient shift needed in bits (NOTE: this number is signed two's-complement).
        public let linearPredictorCoefficientsShift: UInt
        
        /// Unencoded predictor coefficients (NOTE: the coefficients are signed two's-complement).
        public let linearPredictorCoefficients: UInt
        
        public let residual: Residual
        
        
        init(
            handler: inout BitsDecoder,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header,
            order: Int
        ) throws {
            assert(header.bitsPerSample * order % 8 == 0)
            self.unencodedWarmupSamples = try handler.decodeData(bytesCount: header.bitsPerSample * order / 8)
            
            let linearPredictorCoefficientsPrecisions = try handler.decodeInteger(bitsCount: 4)
            if linearPredictorCoefficientsPrecisions != 0b1111 {
                self.linearPredictorCoefficientsPrecisions = linearPredictorCoefficientsPrecisions + 1
            } else {
                throw DecodeError.invalidLinearPredictorCoefficientsPrecisions
            }
            
            self.linearPredictorCoefficientsShift = try UInt(handler.decodeInteger(bitsCount: 5))
            self.linearPredictorCoefficients = try UInt(handler.decodeInteger(bitsCount: linearPredictorCoefficientsPrecisions * order))
            
            self.residual = try Residual(handler: &handler, header: header, subheader: subheader, predicatorOrder: order)
        }
        
        
        public enum DecodeError: Error {
            case invalidLinearPredictorCoefficientsPrecisions
        }
    }
    
}

//
//  LPC Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct LPC {
        
        public let unencodedWarmupSamples: Data
        
        /// Quantized linear predictor coefficients' precision in bits
        public let linearPredictorCoefficientsPrecisions: Int
        
        /// Quantized linear predictor coefficient shift needed in bits.
        public let linearPredictorCoefficientsShift: Int
        
        /// Unencoded predictor coefficients.
        public let linearPredictorCoefficients: Int
        
        public let residual: Residual
        
        
        init(
            handler: inout BitsDecoder,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header,
            order: Int
        ) throws {
            assert(header.bitsPerSample * order % 8 == 0)
            self.unencodedWarmupSamples = try handler.decodeData(bytesCount: header.bitsPerSample * order / 8)
            
            let linearPredictorCoefficientsPrecisions = try handler.decodeInt(encoding: .unsigned(bits: 4))
            if linearPredictorCoefficientsPrecisions != 0b1111 {
                self.linearPredictorCoefficientsPrecisions = linearPredictorCoefficientsPrecisions + 1
            } else {
                throw DecodeError.invalidLinearPredictorCoefficientsPrecisions
            }
            
            self.linearPredictorCoefficientsShift = try handler.decodeInt(encoding: .signed(bits: 5))
            self.linearPredictorCoefficients = try handler.decodeInt(encoding: .signed(bits: linearPredictorCoefficientsPrecisions * order))
            
            self.residual = try Residual(handler: &handler, header: header, subheader: subheader, predicatorOrder: order)
        }
        
        
        public enum DecodeError: Error {
            case invalidLinearPredictorCoefficientsPrecisions
        }
    }
    
}

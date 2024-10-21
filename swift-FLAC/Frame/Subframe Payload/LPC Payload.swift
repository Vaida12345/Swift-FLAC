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
    
    public struct LPC: CustomDetailedStringConvertible {
        
        public let warmup: Warmup
        
        /// Quantized linear predictor coefficients' precision in bits
        public let coefficientsPrecisions: Int
        
        /// Quantized linear predictor coefficient right shift needed in bits.
        public let coefficientsRightShift: Int
        
        /// Unencoded predictor coefficients.
        public let coefficients: [Int]
        
        public let residual: Residual
        
        
        init(
            handler: inout BitsDecoder,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header,
            order: Int,
            index: Int
        ) throws {
            self.warmup = try Warmup(handler: &handler, header: header, index: index, order: order)
            
            let linearPredictorCoefficientsPrecisions = try handler.decodeInt(encoding: .unsigned(bits: 4))
            if linearPredictorCoefficientsPrecisions != 0b1111 {
                self.coefficientsPrecisions = linearPredictorCoefficientsPrecisions + 1
            } else {
                throw DecodeError.invalidLinearPredictorCoefficientsPrecisions
            }
            
            self.coefficientsRightShift = try handler.decodeInt(encoding: .signed(bits: 5))
            
            self.coefficients = try (0..<order).map { _ in
                try handler.decodeInt(encoding: .signed(bits: linearPredictorCoefficientsPrecisions + 1))
            }
            
            self.residual = try Residual(handler: &handler, header: header, subheader: subheader, predicatorOrder: order)
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Subframe.Payload.LPC>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.warmup)
                descriptor.value(for: \.coefficientsPrecisions)
                descriptor.value(for: \.coefficientsRightShift)
                descriptor.value(for: \.coefficients)
                descriptor.value(for: \.residual)
            }
        }
        
        
        public enum DecodeError: Error {
            case invalidLinearPredictorCoefficientsPrecisions
        }
    }
    
}

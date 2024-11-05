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
    
    public struct LPC: CustomDetailedStringConvertible, PayloadProtocol {
        
        public let warmup: Warmup
        
        /// Quantized linear predictor coefficient right shift needed in bits.
        public let rightShift: Int
        
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
            if linearPredictorCoefficientsPrecisions == 0b1111 {
                throw DecodeError.invalidLinearPredictorCoefficientsPrecisions
            }
            
            self.rightShift = try handler.decodeInt(encoding: .signed(bits: 5))
            
            self.coefficients = try (0..<order).map { _ in
                try handler.decodeInt(encoding: .signed(bits: linearPredictorCoefficientsPrecisions + 1))
            }
            
            self.residual = try Residual(handler: &handler, header: header, subheader: subheader, predicatorOrder: order)
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Subframe.Payload.LPC>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.warmup)
                descriptor.value(for: \.rightShift)
                descriptor.value(for: \.coefficients)
                descriptor.value(for: \.residual)
            }
        }
        
        public enum DecodeError: Error {
            case invalidLinearPredictorCoefficientsPrecisions
        }
        
        public func _encodedSequence(
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) -> [Int] {
            guard case .lpc(let order) = subheader.type else {
                fatalError("invalid type")
            }
            
            var sequence = self.warmup.data
            sequence.reserveCapacity(header.blockSize)
            
            let residual = self.residual._encodedSequence(header: header, subheader: subheader, order: order)
            
            var i = 0
            while sequence.count < header.blockSize {
                // To form a prediction, each coefficient is multiplied with its corresponding past sample, the results are summed and this sum is then shifted.
                var sum = 0
                for (offset, coefficient) in coefficients.enumerated() {
                    sum += sequence.element(at: -offset - 1) * coefficient
                }
                sequence.append((sum >> self.rightShift) + residual[i])
                i &+= 1
            }
//            
            return sequence
        }
        
    }
    
}

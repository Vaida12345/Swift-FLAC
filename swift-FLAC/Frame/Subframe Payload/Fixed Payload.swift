//
//  Fixed Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators
import Accelerate


extension FLACContainer.Frame.Subframe.Payload {
    
    public struct Fixed: DetailedStringConvertible, PayloadProtocol {
        
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
        
        public func _encodedSequence(
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) -> [Int] {
            guard case .fixed(let order) = subheader.type else {
                fatalError("invalid type")
            }
            
            var sequence = self.warmup.data
            sequence.reserveCapacity(header.blockSize)
            
            let residual = self.residual._encodedSequence(header: header, subheader: subheader, order: order)
            var i = 0
            
            while sequence.count < header.blockSize {
                switch order {
                case 0:
                    sequence.append(residual[i])
                    
                case 1:
                    sequence.append(sequence.element(at: -1) + residual[i])
                    
                case 2:
                    // 2 * a(n-1) - a(n-2)
                    sequence.append(2 * sequence.element(at: -1) - sequence.element(at: -2) + residual[i])
                    
                case 3:
                    // 3 * a(n-1) - 3 * a(n-2) + a(n-3)
                    sequence.append(3 * sequence.element(at: -1) - 3 * sequence.element(at: -2) + sequence.element(at: -3) + residual[i])
                    
                case 4:
                    // 4 * a(n-1) - 6 * a(n-2) + 4 * a(n-3) - a(n-4)
                    sequence.append(4 * sequence.element(at: -1) - 6 * sequence.element(at: -2) + 4 * sequence.element(at: -3) - sequence.element(at: -4) + residual[i])
                    
                default:
                    fatalError("invalid order")
                }
                
                i &+= 1
            }
            
            return sequence
        }
        
    }
    
}

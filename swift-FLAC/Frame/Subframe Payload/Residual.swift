//
//  Residual.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Frame.Subframe.Payload {
    
    /// FLAC currently defines two similar methods for the coding of the error signal from the prediction stage.
    ///
    /// The error signal is coded using Rice codes in one of two ways: 1) the encoder estimates a single Rice parameter based on the variance of the residual and Rice codes the entire residual using this parameter; 2) the residual is partitioned into several equal-length regions of contiguous samples, and each region is coded with its own Rice parameter based on the region's mean. (Note that the first method is a special case of the second method with one partition, except the Rice parameter is based on the residual variance instead of the mean.)
    ///
    /// - SeeAlso: https://www.ietf.org/archive/id/draft-ietf-cellar-flac-08.pdf
    public struct Residual: CustomDetailedStringConvertible {
        
        public let partitionOrder: Int
        
        public let partitions: [Partition]
        
        
        init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subheader: FLACContainer.Frame.Subframe.Header, predicatorOrder: Int) throws {
            let encodingMethod = try handler.decodeInteger(bitsCount: 2)
            let partitionOrder = try handler.decodeInteger(bitsCount: 4)
            self.partitionOrder = partitionOrder
            self.partitions = try (0..<pow(2, partitionOrder)).map {
                try Partition(
                    handler: &handler,
                    header: header,
                    subheader: subheader,
                    partitionOrder: partitionOrder,
                    predicatorOrder: predicatorOrder,
                    isFirst: $0 == 0,
                    encodingMethod: encodingMethod
                )
            }
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Subframe.Payload.Residual>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.value(for: \.partitionOrder)
                descriptor.value(for: \.partitions)
            }
        }
        
        
        public enum Partition {
            
            /// The residual samples, which are signed numbers, are represented by unsigned numbers in the Rice code. For positive numbers, the representation is the number doubled, for negative numbers, the representation is the number multiplied by -2 and has 1 subtracted.
            case rice(parameters: Int)
            /// The residual samples, which are signed numbers, are represented by unsigned numbers in the Rice code. For positive numbers, the representation is the number doubled, for negative numbers, the representation is the number multiplied by -2 and has 1 subtracted.
            case rice2(parameters: Int)
            /// the partition is in unencoded binary form using n bits per sample
            ///
            /// the Rice coding is not used for this partition. Instead, the residual data is stored unencoded using a fixed number of bits per sample
            ///
            /// The residual samples themselves are stored signed two's complement.
            ///
            /// Note that it is possible that the number of bits with which each sample is stored is 0, which means all residual samples in that partition have a value of 0 and that no bits are used to store the samples. In that case, the partition contains nothing except the escape code and `0b00000`.
            case unencoded(residual: Data, bitsPerSample: Int, samplesCount: Int)
            
            
            init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subheader: FLACContainer.Frame.Subframe.Header, partitionOrder: Int, predicatorOrder: Int, isFirst: Bool, encodingMethod: Int) throws {
                switch encodingMethod {
                case 0b00:
                    let parameter = try handler.decodeInteger(bitsCount: 4)
                    if parameter != 0b1111 {
                        self = .rice(parameters: parameter)
                        return
                    }
                    
                case 0b01:
                    let parameter = try handler.decodeInteger(bitsCount: 5)
                    if parameter != 0b11111 {
                        self = .rice2(parameters: parameter)
                        return
                    }
                    
                default:
                    throw DecodeError.reservedResidualCodingMethod
                }
                
                let bitsPerSample = try handler.decodeInteger(bitsCount: 5)
                let numberOfSamples = if !isFirst {
                    header.blockSize >> partitionOrder // blockSize / 2 ** partitionOrder
                } else {
                    header.blockSize >> partitionOrder - predicatorOrder
                }
                
                
                guard numberOfSamples > 0 else { throw DecodeError.invalidResidualLength }
                let length = bitsPerSample * numberOfSamples
                assert(length % 8 == 0)
                self = try .unencoded(
                    residual: handler.decodeData(bytesCount: length / 8),
                    bitsPerSample: bitsPerSample,
                    samplesCount: numberOfSamples
                )
            }
            
            
            public enum DecodeError: Error {
                case reservedResidualCodingMethod
                case invalidResidualLength
            }
        }
        
    }
    
}

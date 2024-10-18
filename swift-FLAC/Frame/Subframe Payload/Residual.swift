//
//  Residual.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription


extension FLACContainer.Frame.Subframe.Payload {
    
    /// FLAC currently defines two similar methods for the coding of the error signal from the prediction stage.
    ///
    /// The error signal is coded using Rice codes in one of two ways: 1) the encoder estimates a single Rice parameter based on the variance of the residual and Rice codes the entire residual using this parameter; 2) the residual is partitioned into several equal-length regions of contiguous samples, and each region is coded with its own Rice parameter based on the region's mean. (Note that the first method is a special case of the second method with one partition, except the Rice parameter is based on the residual variance instead of the mean.)
    public struct Residual {
        
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
        
        
        public enum Partition {
            
            case rice(parameters: Int)
            case rice2(parameters: Int)
            /// the partition is in unencoded binary form using n bits per sample
            ///
            /// the Rice coding is not used for this partition. Instead, the residual data is stored unencoded using a fixed number of bits per sample
            case unencoded(residual: Data)
            
            
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
                        self = .rice(parameters: parameter)
                        return
                    }
                    
                default:
                    throw DecodeError.reservedResidualCodingMethod
                }
                
                let bitsPerSample = try handler.decodeInteger(bitsCount: 5)
                let numberOfSamples = if partitionOrder == 0 {
                    header.blockSize - predicatorOrder
                } else if !isFirst {
                    header.blockSize / pow(2, partitionOrder)
                } else {
                    header.blockSize / pow(2, partitionOrder) - predicatorOrder
                }
                let length = bitsPerSample * numberOfSamples
                assert(length % 8 == 0)
                self = try .unencoded(residual: handler.decodeData(bytesCount: length / 8))
            }
            
            
            public enum DecodeError: Error {
                case reservedResidualCodingMethod
            }
        }
        
    }
    
}

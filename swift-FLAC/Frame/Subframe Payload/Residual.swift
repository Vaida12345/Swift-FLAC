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
    public struct Residual: DetailedStringConvertible {
        
        public let partitionOrder: Int
        
        public let partitions: [Partition]
        
        
        init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subheader: FLACContainer.Frame.Subframe.Header, predicatorOrder: Int) throws {
            let encodingMethod = try handler.decode(bitsCount: 2, as: UInt8.self)
            let partitionOrder = try handler.decodeInt(encoding: .unsigned(bits: 4))
            self.partitionOrder = partitionOrder
            
            self.partitions = try (0..<(1 << partitionOrder)).map {
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
//                descriptor.value(for: \.partitions)
                descriptor.constant("partitions: <\(partitions.count) elements>")
            }
        }
        
        
        public enum Partition: DetailedStringConvertible {
            
            /// The residual samples, which are signed numbers, are represented by unsigned numbers in the Rice code. For positive numbers, the representation is the number doubled, for negative numbers, the representation is the number multiplied by -2 and has 1 subtracted.
            case encoded(version: Version, content: [Int])
            /// the partition is in unencoded binary form using n bits per sample
            ///
            /// the Rice coding is not used for this partition. Instead, the residual data is stored unencoded using a fixed number of bits per sample
            ///
            /// The residual samples themselves are stored signed two's complement.
            ///
            /// Note that it is possible that the number of bits with which each sample is stored is 0, which means all residual samples in that partition have a value of 0 and that no bits are used to store the samples. In that case, the partition contains nothing except the escape code and `0b00000`.
            case unencoded(residual: [Int], bitsPerSample: Int)
            
            case empty
            
            
            init(handler: inout BitsDecoder, header: FLACContainer.Frame.Header, subheader: FLACContainer.Frame.Subframe.Header, partitionOrder: Int, predicatorOrder: Int, isFirst: Bool, encodingMethod: UInt8) throws {
                var version: Version? = nil
                var parameter: Int
                
                switch encodingMethod {
                case 0b00:
                    parameter = try handler.decodeInt(encoding: .unsigned(bits: 4))
                    if parameter != 0b1111 {
                        version = .rice
                    }
                    
                case 0b01:
                    parameter = try handler.decodeInt(encoding: .unsigned(bits: 5))
                    if parameter != 0b11111 {
                        version = .rice2
                    }
                    
                default:
                    throw DecodeError.reservedResidualCodingMethod
                }
                
                let numberOfSamples = if !isFirst {
                    header.blockSize >> partitionOrder // blockSize / 2 ** partitionOrder
                } else {
                    (header.blockSize >> partitionOrder) - predicatorOrder
                }
                
                guard numberOfSamples > 0 else {
                    self = .empty
                    return
                }
                
                if let version {
                    let elements = try (0..<numberOfSamples).map { _ in
                        let quotient = try handler.decodeInt(encoding: .unary)
                        let remainder = try handler.decodeInt(encoding: .unsigned(bits: parameter))
                        
                        let folded = (quotient << parameter) | remainder
                        if folded.isMultiple(of: 2) {
                            return folded >> 1
                        } else {
                            return ~(folded >> 1)
                        }
                    }
                    
                    self = .encoded(version: version, content: elements)
                } else {
                    let bitsPerSample = try handler.decodeInt(encoding: .signed(bits: 5))
                    
                    if bitsPerSample == 0 {
                        self = .unencoded(
                            residual: [Int](repeating: 0, count: numberOfSamples),
                            bitsPerSample: bitsPerSample
                        )
                    } else {
                        let residual = try (0..<numberOfSamples).map { _ in
                            try handler.decodeInt(encoding: .signed(bits: bitsPerSample))
                        }
                        
                        self = .unencoded(
                            residual: residual,
                            bitsPerSample: bitsPerSample
                        )
                    }
                }
            }
            
            public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Subframe.Payload.Residual.Partition>) -> any DescriptionBlockProtocol {
                switch self {
                case let .encoded(version, content):
                    descriptor.container("encoded") {
                        descriptor.value("version", of: version)
//                        descriptor.value("content", of: content)
                        descriptor.constant("content: <Array \(content.count) elements>")
                    }
                case let .unencoded(residual, _):
                    descriptor.container("unencoded") {
                        descriptor.value("residual", of: residual)
                        descriptor.constant("residual: <Array \(residual.count) elements>")
//                        descriptor.value("bitsPerSample", of: bitsPerSample)
                    }
                case .empty:
                    descriptor.constant("empty")
                }
            }
            
            
            public enum DecodeError: Error {
                case reservedResidualCodingMethod
                case invalidResidualLength
            }
            
            public enum Version {
                case rice
                case rice2
            }
        }
        
        
        public func _encodedSequence(
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header,
            order: Int
        ) -> [Int] {
            let residual = self.partitions.flatMap { partition in
                switch partition {
                case .encoded(_, let content):
                    return content
                case .unencoded(let residual, _):
                    return residual
                case .empty:
                    return []
                }
            }
            
            assert(residual.count == header.blockSize - order)
            
            return residual
        }
        
    }
    
}

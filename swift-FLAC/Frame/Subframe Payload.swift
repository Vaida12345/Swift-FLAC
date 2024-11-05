//
//  Subframe Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//


import Foundation
import DetailedDescription


extension FLACContainer.Frame.Subframe {
    
    public enum Payload: CustomDetailedStringConvertible, PayloadProtocol {
        case constant(Constant)
        case fixed(Fixed)
        case lpc(LPC)
        case verbatim(Verbatim)
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FLACContainer.Frame.Subframe.Payload>) -> any DescriptionBlockProtocol {
            switch self {
            case .constant(let constant): descriptor.value("", of: constant)
            case .fixed(let fixed): descriptor.value("", of: fixed)
            case .lpc(let lpc): descriptor.value("", of: lpc)
            case .verbatim(let verbatim): descriptor.value("", of: verbatim)
            }
        }
        
        public func _encodedSequence(
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) -> [Int] {
            switch self {
            case .constant(let payload): payload._encodedSequence(header: header, subheader: subheader)
            case .fixed(let payload): payload._encodedSequence(header: header, subheader: subheader)
            case .lpc(let payload): payload._encodedSequence(header: header, subheader: subheader)
            case .verbatim(let payload): payload._encodedSequence(header: header, subheader: subheader)
            }
        }
        
        public func _write(
            to buffer: UnsafeMutablePointer<UInt8>,
            stride: Int,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) {
            switch self {
            case .constant(let payload): payload._write(to: buffer, stride: stride, header: header, subheader: subheader)
            case .fixed(let payload): payload._write(to: buffer, stride: stride, header: header, subheader: subheader)
            case .lpc(let payload): payload._write(to: buffer, stride: stride, header: header, subheader: subheader)
            case .verbatim(let payload): payload._write(to: buffer, stride: stride, header: header, subheader: subheader)
            }
        }
        
        public typealias PayloadProtocol = FLACContainer.Frame.Subframe.PayloadProtocol
        
    }
    
}

//
//  Subframe Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//


import Foundation
import DetailedDescription


extension FLACContainer.Frame.Subframe {
    
    public enum Payload: CustomDetailedStringConvertible {
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
    }
    
}

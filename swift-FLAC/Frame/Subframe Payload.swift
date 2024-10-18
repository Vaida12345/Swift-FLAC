//
//  Subframe Payload.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//


import Foundation
import DetailedDescription


extension FLACContainer.Frame.Subframe {
    
    public enum Payload {
        case constant(Constant)
        case fixed(Fixed)
        case lpc(LPC)
        case verbatim(Verbatim)
    }
    
}

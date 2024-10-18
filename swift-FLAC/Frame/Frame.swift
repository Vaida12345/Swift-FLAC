//
//  Frame.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


extension FLACContainer {
    
    public struct Frame {
        
        public let header: Header
        
        
        
        init(handler: inout BitsDecoder) throws {
            self.header = try Header(handler: &handler)
        }
        
    }
    
}

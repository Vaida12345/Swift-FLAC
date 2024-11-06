//
//  ApplicationBlock.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription
import BitwiseOperators


extension FLACContainer.Metadata {
    
    /// This block is for use by third-party applications.
    ///
    /// The ``id`` is granted upon request to an application by the FLAC maintainers. The remainder is of the block (``data``) is defined by the registered application. Visit the [registration page](https://xiph.org/flac/id.html) if you would like to register an ID for your application with FLAC.
    public struct ApplicationBlock {
        
        /// Registered application ID. (Visit the [registration page](https://xiph.org/flac/id.html) to register an ID with FLAC.)
        public let id: UInt32
        
        /// Application data (n must be a multiple of 8)
        public let data: Data
        
        init(data: Data) throws {
            var handler = BitsDecoder(data)
            
            self.id = try handler.decode(bitsCount: 32)
            self.data = handler.data[(handler.bitIndex / 8)...]
        }
        
    }
    
}

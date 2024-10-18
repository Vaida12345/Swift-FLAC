//
//  ApplicationBlock.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import DetailedDescription


extension FLACContainer.Metadata {
    
    /// This block is for use by third-party applications.
    ///
    /// The only mandatory field is a 32-bit identifier. This ID is granted upon request to an application by the FLAC maintainers. The remainder is of the block is defined by the registered application. Visit the [registration page](https://xiph.org/flac/id.html) if you would like to register an ID for your application with FLAC.

    public struct ApplicationBlock {
        
        let id: Int
        
        let data: Data
        
        public init?(data: Data) {
            var handler = BitsDecoder(data)
            
            do {
                self.id = try handler.decodeInteger(bitsCount: 32)
                self.data = handler.data[(handler.bitIndex / 8)...]
            } catch {
                return nil
            }
        }
        
    }
    
}

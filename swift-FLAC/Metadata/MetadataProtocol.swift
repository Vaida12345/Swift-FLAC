//
//  MetadataProtocol.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


extension FLACContainer.Metadata {
    
    public protocol MetadataProtocol {
        
        init?(data: Data) 
        
    }
    
}

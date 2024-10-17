//
//  FLACContainer.swift
//  swift-FLAC
//
//  Created by Vaida on 10/17/24.
//

import Foundation


public struct FLACContainer {
    
    private let metadata: [Metadata]
    
    
    init(from source: URL) throws {
        
        let handle = try FileHandle(forReadingFrom: source)
        
        guard let nextData = try handle.read(upToCount: 4),
              String(data: nextData, encoding: .ascii) == "fLaC" else { throw DecodeError.notFLAC }
        
        
        var isLastMetadata = false
        var metadata: [Metadata] = []
        
        while !isLastMetadata {
            let new = try Metadata(handle: handle, metaDataIsLast: &isLastMetadata)
            metadata.append(new)
        }
        
        self.metadata = metadata
        
        
        
    }
    
    
    enum DecodeError: Error {
        case notFLAC
    }
    
}

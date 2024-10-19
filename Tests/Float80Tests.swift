//
//  Float80Tests.swift
//  Swift-FLAC
//
//  Created by Vaida on 10/19/24.
//

import Testing
@testable
import SwiftAIFF


@Suite
struct Float80Tests {
    @Test
    func conversion() throws {
        let double = Double.random(in: -1000000 ... 1000000)
        #expect(Double(Float80(double)) == double)
    }
}

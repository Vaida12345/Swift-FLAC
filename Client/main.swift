//
//  main.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation
import SwiftFLAC
import DetailedDescription


let url = URL(fileURLWithPath: "/Users/vaida/Music/mora/Evan Call/TVアニメ『葬送のフリーレン』Original Soundtrack/01-Journey of a Lifetime ~ Frieren Main Theme.flac")

let container = try FLACContainer(at: url)
detailedPrint(container)

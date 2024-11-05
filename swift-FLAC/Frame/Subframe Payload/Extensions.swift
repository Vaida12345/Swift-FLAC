//
//  Extensions.swift
//  Swift-FLAC
//
//  Created by Vaida on 11/5/24.
//


extension Array {
    
    /// Subscript using the reversed index.
    ///
    /// `array[reversed: -1]` is the last element.
    /// `array[reversed: -2]` is the second last element.
    @inlinable
    func element(at: Int) -> Element {
        self[self.count &+ at]
    }
    
}

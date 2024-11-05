//
//  Payload Protocol.swift
//  Swift-FLAC
//
//  Created by Vaida on 11/5/24.
//

extension FLACContainer.Frame.Subframe {
    
    public protocol PayloadProtocol {
        
        /// Writes the contents of this payload to the given buffer.
        ///
        /// The returned sequence is subject to Interchannel Decorrelation.
        ///
        /// - Parameters:
        ///   - buffer: The destination. Shifted in the way that the index of `0` is aligned with the payload data.
        ///   - stride: The distance in *samples* between the start of two consecutive sample. `1` for contiguous data.
        ///   - header: The frame header
        func _write(
            to buffer: UnsafeMutablePointer<UInt8>,
            stride: Int,
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        )
        
        /// Returns the linear PCM representation of this payload.
        ///
        /// The returned sequence is subject to Interchannel Decorrelation.
        ///
        /// - Parameters:
        ///   - header: The frame header
        ///
        /// - Returns: Array of integers of length `header.blockSize`.
        ///
        /// - Complexity: O(*n*) worse case.
        func _encodedSequence(
            header: FLACContainer.Frame.Header,
            subheader: FLACContainer.Frame.Subframe.Header
        ) -> [Int]
        
    }
    
}


public extension FLACContainer.Frame.Subframe.PayloadProtocol {
    
    static func _write(
        sequence: [Int],
        to buffer: UnsafeMutablePointer<UInt8>,
        stride: Int,
        header: FLACContainer.Frame.Header
    ) {
        var destIndex = 0
        let bytesPerSample = header.bitsPerSample / 8
        
        var iteratorIndex = 0
        while iteratorIndex < sequence.count {
            // obtain the correct bit width data
            // swift int is 64bit, flac supports up to 32bit int.
            let data = sequence[iteratorIndex].bigEndian.data.suffix(bytesPerSample)
            
            data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
                ptr.withMemoryRebound(to: UInt8.self) { ptr in
                    var ii = 0
                    while ii < bytesPerSample {
                        (buffer + destIndex).initialize(to: ptr[ii])
                        
                        destIndex &+= 1
                        ii &+= 1
                    }
                }
            }
            
            destIndex &+= (stride &- 1) * bytesPerSample
            iteratorIndex &+= 1
        }
    }
    
    func _write(
        to buffer: UnsafeMutablePointer<UInt8>,
        stride: Int,
        header: FLACContainer.Frame.Header,
        subheader: FLACContainer.Frame.Subframe.Header
    ) {
        Self._write(
            sequence: self._encodedSequence(header: header, subheader: subheader),
            to: buffer,
            stride: stride,
            header: header
        )
    }
}

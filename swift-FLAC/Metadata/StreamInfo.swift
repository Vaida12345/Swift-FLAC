//
//  MetadataStreamInfo.swift
//  swift-FLAC
//
//  Created by Vaida on 10/18/24.
//

import Foundation


extension FLACContainer.Metadata {
    
    public struct StreamInfo: MetadataProtocol {
        
        /// The minimum block size (in samples) used in the stream.
        let minimumBlockSize: Int
        
        /// The maximum block size (in samples) used in the stream. (Minimum blocksize == maximum blocksize) implies a fixed-blocksize stream.
        let maximumBlockSize: Int
        
        /// The minimum frame size (in bytes) used in the stream. May be 0 to imply the value is not known.
        let minimumFrameSize: Int
        
        /// The maximum frame size (in bytes) used in the stream. May be 0 to imply the value is not known.
        let maximumFrameSize: Int
        
        /// Sample rate in Hz. Though 20 bits are available, the maximum sample rate is limited by the structure of frame headers to 655350Hz. Also, a value of 0 is invalid.
        let sampleRate: Int
        
        /// Number of channels. FLAC supports from 1 to 8 channels
        let channelsCount: Int
        
        /// Bits per sample. FLAC supports from 4 to 32 bits per sample.
        let bitsPerSample: Int
        
        /// Total samples in stream. 'Samples' means inter-channel sample, i.e. one second of 44.1Khz audio will have 44100 samples regardless of the number of channels. A value of zero here means the number of total samples is unknown.
        let samplesCount: Int
        
        /// MD5 signature of the unencoded audio data. This allows the decoder to determine if an error exists in the audio data even when the error does not result in an invalid bitstream.
        let md5Signature: Data
        
        
        /// FLAC specifies a minimum block size of 16 and a maximum block size of 65535, meaning the bit patterns corresponding to the numbers 0-15 in the minimum blocksize and maximum blocksize fields are invalid.
        public init?(data: Data) {
            guard data.count == 252 else { return nil }
            var handler = BitsDecoder(data)
            
            
            return nil 
        }
    }
    
}

# ``SwiftFLAC``

Swift Parser & Converter of FLAC.

## Overview

FLAC (Free Lossless Audio Codec) is an audio coding format for lossless compression of digital audio, developed by the [Xiph.Org](https://xiph.org) Foundation.

- SeeAlso: This package uses the specifications issued [here](https://xiph.org/flac/format.html).

In this package, ``FLACContainer`` encapsulates FLAC documents. The ``FLACContainer/metadata-swift.property`` encodes the metadata, and ``FLACContainer/frames`` encodes the raw frames. 


## Topics

### Initialize a document

- ``FLACContainer/init(at:options:))``
- ``FLACContainer/init(data:options:))``

### Inspect metadata

- ``FLACContainer/metadata-swift.property``
- ``FLACContainer/Metadata-swift.struct``

### Obtain audio data

- ``FLACContainer/interleavedAudioData()``
- ``FLACContainer/write(to:)``

### Raw Frames

The frames that encode audio data. This is an implementation detail.

- ``FLACContainer/frames``

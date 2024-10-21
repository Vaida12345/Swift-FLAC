# Swift FLAC
Swift native implementation of a FLAC reader.

## Features
- [x] Full FLAC file parsing.
- [x] Extract PCM data from verbatim-encoded (uncompressed) FLAC files.
- [x] Convert verbatim-encoded (uncompressed) FLAC files to AIFF.
- [ ] Convert any FLAC file to AIFF.
- [x] Optimized. 

## Example
```swift
let url = URL(fileURLWithPath: "file.flac")

// Creates a document using the given URL.
let container = try FLACContainer(at: url)

// Inspect the container using [DetailedDescription](https://github.com/Vaida12345/DetailedDescription)
detailedPrint(container)

// Inspect the metadata
detailedPrint(container.metadata)

// Gets interleaved audio data
let data = container.interleavedAudioData()

// Write the document as aiff
container.write(to: .desktopDirectory.appending(path: "file.aiff"))
```

## Getting Started

`Swift-FLAC` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/) as its build tool. If you want to import in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/Vaida12345/Swift-FLAC.git", branch: "main")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
https://github.com/Vaida12345/Swift-FLAC
```

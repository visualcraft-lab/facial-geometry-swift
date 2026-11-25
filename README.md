# facial-geometry-swift

Zero-dependency Swift package for computing 2D facial landmark geometry metrics (canthal tilt, facial thirds balance, golden ratio delta, and bilateral mirror symmetry).

## Installation

Add `facial-geometry-swift` to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/visualcraft-lab/facial-geometry-swift.git", from: "0.1.0")
]
```

Then add `"FacialGeometry"` to your target dependencies.

## Usage

```swift
import FacialGeometry

let tilt = try FacialGeometry.canthalTiltDegrees(
    medial: .init(x: 100, y: 200),
    lateral: .init(x: 140, y: 195)
)
print(String(format: "Canthal tilt: %.2f deg", tilt))

let thirds = try FacialGeometry.computeFacialThirds(
    trichionY: 100,
    glabellaY: 200,
    subnasaleY: 300,
    mentonY: 400
)
print("Balance score:", thirds.balanceScore)
```

## Reference & Online Calculator

Interactive visual verification and landmark definitions:
- [Looksmax Scale](https://looksmaxscale.com/)
- [Canthal Tilt Measurement Guide](https://looksmaxscale.com/canthal-tilt)
- [Facial Proportion Reference](https://looksmaxscale.com/attractiveness-test)

## License

MIT

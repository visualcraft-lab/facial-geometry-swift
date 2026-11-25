// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FacialGeometry",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "FacialGeometry",
            targets: ["FacialGeometry"]
        )
    ],
    targets: [
        .target(
            name: "FacialGeometry"
        ),
        .testTarget(
            name: "FacialGeometryTests",
            dependencies: ["FacialGeometry"]
        )
    ]
)

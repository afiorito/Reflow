// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Reflow",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Reflow",
            targets: ["Reflow"]
        ),
    ],
    targets: [
        .target(
            name: "Reflow",
            dependencies: []
        ),
        .testTarget(
            name: "ReflowTests",
            dependencies: ["Reflow"]
        ),
    ]
)

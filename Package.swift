// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Reflow",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
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

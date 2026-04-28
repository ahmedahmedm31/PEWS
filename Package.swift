// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PEWS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PEWS",
            targets: ["PEWS"]
        )
    ],
    targets: [
        .target(
            name: "PEWS",
            dependencies: [],
            path: "Sources/PEWS",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PEWSTests",
            dependencies: ["PEWS"],
            path: "Sources/PEWSTests"
        )
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CommandQueue",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "cq", targets: ["CommandQueue"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
    ],
    targets: [
        .executableTarget(
            name: "CommandQueue",
            dependencies: ["CommandQueueCLI"]
        ),
        .target(
            name: "CommandQueueCLI",
            dependencies: [
                "CommandQueueKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "CommandQueueKit"),
        .testTarget(
            name: "CommandQueueCLITests",
            dependencies: ["CommandQueueCLI"]
        ),
        .testTarget(
            name: "CommandQueueKitTests",
            dependencies: ["CommandQueueKit"]
        ),
    ]
)

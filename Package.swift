// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SwiftHooks",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "SwiftHooks", targets: ["SwiftHooks"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", "1.2.0"..<"3.0.0")
    ],
    targets: [
        .target(
            name: "SwiftHooks",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Metrics", package: "swift-metrics"),
        ]),
        .testTarget(
            name: "SwiftHooksTests",
            dependencies: [
                .target(name: "SwiftHooks")
        ]),
    ]
)

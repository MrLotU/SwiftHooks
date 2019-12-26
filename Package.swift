// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftHooks",
    platforms: [
       .macOS(.v10_14)
    ],
    products: [
        .library(name: "SwiftHooks", targets: ["SwiftHooks"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "SwiftHooks",
            dependencies: ["Logging", "NIO", "Metrics"]),
        .testTarget(
            name: "SwiftHooksTests",
            dependencies: ["SwiftHooks"]),
    ]
)

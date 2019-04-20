// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftHooks",
    products: [
        .library(name: "SwiftHooks", targets: ["SwiftHooks"]),
        .library(name: "SwiftHooksDiscord", targets: ["SwiftHooksDiscord"]),
        .executable(name: "SwiftHooksExample", targets: ["SwiftHooksExample"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftHooks",
            dependencies: ["Logging"]),
        .target(
            name: "SwiftHooksDiscord",
            dependencies: ["SwiftHooks"]),
        .target(
            name: "SwiftHooksExample",
            dependencies: ["SwiftHooks", "SwiftHooksDiscord"]),
        .testTarget(
            name: "SwiftHooksTests",
            dependencies: ["SwiftHooks"]),
    ]
)

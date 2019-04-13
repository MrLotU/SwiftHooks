// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftHooks",
    products: [
        .library(
            name: "SwiftHooks",
            targets: ["SwiftHooks"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "SwiftHooks",
            dependencies: []),
        .target(
            name: "SwiftHooksExample",
            dependencies: ["SwiftHooks"]
            ),
        .testTarget(
            name: "SwiftHooksTests",
            dependencies: ["SwiftHooks"]),
    ]
)

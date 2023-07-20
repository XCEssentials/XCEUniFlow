// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "XCEUniFlow",
    platforms: [
        .macOS(.v10_15), // depends on Combine
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "XCEUniFlow",
            targets: [
                "XCEUniFlow"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/XCEssentials/XCERequirement",
            .upToNextMinor(from: "2.6.0")),
        .package(
            url: "https://github.com/XCEssentials/XCEPipeline",
            .upToNextMinor(from: "3.9.0")),
    ],
    targets: [
        .target(
            name: "XCEUniFlow",
            dependencies: [
                "XCERequirement",
                "XCEPipeline"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "XCEUniFlowTests",
            dependencies: [
                "XCEUniFlow",
                "XCERequirement",
                "XCEPipeline"
            ],
            path: "Tests"
        ),
    ]
)

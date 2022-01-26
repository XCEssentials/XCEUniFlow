// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "XCEUniFlow",
    platforms: [
        .macOS(.v10_15), // depends on Combine
        .iOS(.v15)
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
            name: "XCERequirement",
            url: "https://github.com/XCEssentials/Requirement",
            .upToNextMajor(from: "2.3.0")),
        .package(
            name: "XCEPipeline",
            url: "https://github.com/XCEssentials/Pipeline",
            .upToNextMajor(from: "3.7.0")),
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

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
            name: "XCEByTypeStorage",
            url: "https://github.com/XCEssentials/ByTypeStorage",
            .upToNextMinor(from: "3.12.0")),
        .package(
            name: "XCERequirement",
            url: "https://github.com/XCEssentials/Requirement",
            .upToNextMinor(from: "2.3.0")),
        .package(
            name: "XCEPipeline",
            url: "https://github.com/XCEssentials/Pipeline",
            .upToNextMinor(from: "3.7.0")),
        .package(
            name: "SwiftHamcrest",
            url: "https://github.com/nschum/SwiftHamcrest",
            .upToNextMinor(from: "2.2.0"))
    ],
    targets: [
        .target(
            name: "XCEUniFlow",
            dependencies: [
                "XCEByTypeStorage",
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
                "XCEPipeline",
                "SwiftHamcrest"
            ],
            path: "Tests"
        ),
    ]
)

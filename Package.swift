// swift-tools-version:5.8

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
            url: "https://github.com/XCEssentials/XCERequirement",
            .upToNextMinor(from: "2.6.0")
        ),
        .package(
            url: "https://github.com/XCEssentials/XCEPipeline",
            .upToNextMinor(from: "3.9.0")
        ),
    ],
    targets: [
        .target(
            name: "XCEUniFlow",
            dependencies: [
                .product(name: "XCERequirement", package: "XCERequirement"),
                .product(name: "XCEPipeline", package: "XCEPipeline")
            ]
        ),
        .testTarget(
            name: "XCEUniFlowTests",
            dependencies: [
                "XCEUniFlow",
                .product(name: "XCERequirement", package: "XCERequirement"),
                .product(name: "XCEPipeline", package: "XCEPipeline")
            ]
        ),
    ]
)

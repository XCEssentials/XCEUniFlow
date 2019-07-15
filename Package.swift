// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "XCEUniFlow",
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
            url: "https://github.com/XCEssentials/Requirement",
            from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "XCEUniFlow",
            dependencies: [
                "XCERequirement"
            ],
            path: "Sources/Core"
        ),
        .testTarget(
            name: "XCEUniFlowAllTests",
            dependencies: [
                "XCEUniFlow"
            ],
            path: "Tests/AllTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
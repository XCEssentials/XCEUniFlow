// swift-tools-version:5.3

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
        .package(name: "XCERequirement", url: "https://github.com/XCEssentials/Requirement", from: "2.0.0"),
        .package(name: "XCEPipeline", url: "https://github.com/XCEssentials/Pipeline", from: "3.0.0"),
        .package(name: "SwiftHamcrest", url: "https://github.com/nschum/SwiftHamcrest", from: "2.1.1")
    ],
    targets: [
        .target(
            name: "XCEUniFlow",
            dependencies: [
                "XCERequirement",
                "XCEPipeline"
            ],
            path: "Sources/Core"
        ),
        .testTarget(
            name: "XCEUniFlowAllTests",
            dependencies: [
                "XCEUniFlow",
                "XCERequirement",
                "XCEPipeline",
                "SwiftHamcrest"
            ],
            path: "Tests/AllTests"
        ),
    ]
)
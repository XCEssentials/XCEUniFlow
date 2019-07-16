// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "UniFlowSetup",
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
        .package(url: "https://github.com/XCEssentials/RepoConfigurator", from: "2.7.0")
    ],
    targets: [
        .target(
            name: "UniFlowSetup",
            dependencies: ["XCERepoConfigurator", "PathKit"],
            path: ".",
            sources: ["main.swift"]
        )
    ]
)

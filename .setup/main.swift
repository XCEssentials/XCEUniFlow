import PathKit

import XCERepoConfigurator

// MARK: - PRE-script invocation output

print("\n")
print("--- BEGIN of '\(Executable.name)' script ---")

// MARK: -

// MARK: Parameters

let dependencies = (
    requirement: (
        name: """
            XCERequirement
            """,
        carthage: """
            github "XCEssentials/Requirement"
            """,
        swiftPM: """
            .package(url: "https://github.com/XCEssentials/Requirement", from: "2.0.0")
            """
    ),
    pipeline: (
        name: """
            XCEPipeline
            """,
        carthage: """
            github "XCEssentials/Pipeline"
            """,
        swiftPM: """
            .package(url: "https://github.com/XCEssentials/Pipeline", from: "3.0.0")
            """
    ),
    swiftHamcrest: (
        name: """
            SwiftHamcrest
            """,
        swiftPM: """
            .package(url: "https://github.com/nschum/SwiftHamcrest", from: "2.1.1")
            """
    )
)

Spec.BuildSettings.swiftVersion.value = "5.0"
let swiftLangVersions = "[.v5]"

let localRepo = try Spec.LocalRepo.current()

let remoteRepo = try Spec.RemoteRepo(
    accountName: localRepo.context,
    name: localRepo.name
)

let travisCI = (
    address: "https://travis-ci.com/\(remoteRepo.accountName)/\(remoteRepo.name)",
    branch: "master"
)

let company = (
    prefix: "XCE",
    name: remoteRepo.accountName
)

let project = (
    name: remoteRepo.name,
    summary: "Uni-directional data flow & finite state machine merged together",
    copyrightYear: 2016
)

let product = (
    name: company.prefix + project.name,
    bundleId: "com.\(remoteRepo.accountName).\(remoteRepo.name)"
)

let authors = [
    ("Maxim Khatskevich", "maxim@khatskevi.ch")
]

typealias PerSubSpec<T> = (
    core: T,
    tests: T
)

let subSpecs: PerSubSpec = (
    "Core",
    "AllTests"
)

let targetNames: PerSubSpec = (
    product.name,
    product.name + subSpecs.tests
)

let sourcesLocations: PerSubSpec = (
    Spec.Locations.sources + subSpecs.core,
    Spec.Locations.tests + subSpecs.tests
)

let swiftPMPackageManifestFileName = "Package.swift"
let cartfileFileName = "Cartfile"
let prepareForCarthageXcconfigFileName = "PrepareForCarthage.xcconfig"
let prepareForCarthageShFileName = "PrepareForCarthage.sh"

// MARK: Parameters - Summary

localRepo.report()
remoteRepo.report()

// MARK: -

// MARK: Write - ReadMe

try ReadMe()
    .addGitHubLicenseBadge(
        account: company.name,
        repo: project.name
    )
    .addGitHubTagBadge(
        account: company.name,
        repo: project.name
    )
    .addSwiftPMCompatibleBadge()
    .addWrittenInSwiftBadge(
        version: Spec.BuildSettings.swiftVersion.value
    )
    .addStaticShieldsBadge(
        "platforms",
        status: "macOS | iOS | tvOS | watchOS | Linux",
        color: "blue",
        title: "Supported platforms",
        link: "Package.swift"
    )
    .add("""
        [![Build Status](\(travisCI.address).svg?branch=\(travisCI.branch))](\(travisCI.address))
        """
    )
    .add("""

        # \(project.name)

        \(project.summary)

        """
    )
    .prepare(
        removeRepeatingEmptyLines: false
    )
    .writeToFileSystem(
        ifFileExists: .skip
    )

// MARK: Write - License

try License
    .MIT(
        copyrightYear: UInt(project.copyrightYear),
        copyrightEntity: authors.map{ $0.0 }.joined(separator: ", ")
    )
    .prepare()
    .writeToFileSystem()

// MARK: Write - GitHub - PagesConfig

try GitHub
    .PagesConfig()
    .prepare()
    .writeToFileSystem()

// MARK: Write - Git - .gitignore

try Git
    .RepoIgnore()
    .addMacOSSection()
    .addCocoaSection()
    .addSwiftPackageManagerSection(ignoreSources: true)
    .add(
        """
        # we don't need to store project file,
        # as we generate it on-demand
        *.\(Xcode.Project.extension)
        """
    )
    .prepare()
    .writeToFileSystem()

// MARK: Write - Package.swift

try CustomTextFile("""
    // swift-tools-version:\(Spec.BuildSettings.swiftVersion.value)

    import PackageDescription

    let package = Package(
        name: "\(product.name)",
        products: [
            .library(
                name: "\(product.name)",
                targets: [
                    "\(targetNames.core)"
                ]
            )
        ],
        dependencies: [
            \(dependencies.requirement.swiftPM),
            \(dependencies.pipeline.swiftPM),
            \(dependencies.swiftHamcrest.swiftPM)
        ],
        targets: [
            .target(
                name: "\(targetNames.core)",
                dependencies: [
                    "\(dependencies.requirement.name)",
                    "\(dependencies.pipeline.name)"
                ],
                path: "\(sourcesLocations.core)"
            ),
            .testTarget(
                name: "\(targetNames.tests)",
                dependencies: [
                    "\(targetNames.core)",
                    "\(dependencies.requirement.name)",
                    "\(dependencies.pipeline.name)",
                    "\(dependencies.swiftHamcrest.name)"
                ],
                path: "\(sourcesLocations.tests)"
            ),
        ],
        swiftLanguageVersions: \(swiftLangVersions)
    )
    """
    )
    .prepare(
        at: [swiftPMPackageManifestFileName]
    )
    .writeToFileSystem()

// MARK: Write - Cartfile

try CustomTextFile("""
    \(dependencies.requirement.carthage)
    \(dependencies.pipeline.carthage)
    """
    )
    .prepare(
        at: [cartfileFileName]
    )
    .writeToFileSystem()

// MARK: Write - PrepareForCarthage.xcconfig

try CustomTextFile("""
    PRODUCT_BUNDLE_IDENTIFIER = "\(product.bundleId)"
    CURRENT_PROJECT_VERSION = 1
    VERSIONING_SYSTEM = "apple-generic"
    """
    )
    .prepare(
        at: [prepareForCarthageXcconfigFileName]
    )
    .writeToFileSystem()

// MARK: Write - PrepareForCarthage.sh

try CustomTextFile("""
    #!/bin/bash
    # http://www.grymoire.com/Unix/Sed.html#TOC

    currentVersion=$1

    #---

    productName="\(product.name)"
    bundleId="\(product.bundleId)"

    xcconfigFile="\(prepareForCarthageXcconfigFileName)"

    #---

    echo "ℹ️ Preparing $productName for Carthage."

    echo "Updating xcconfig file with version $currentVersion..."
    sed -i '' -e "s|^CURRENT_PROJECT_VERSION = .*$|CURRENT_PROJECT_VERSION = $currentVersion|g" $xcconfigFile

    echo "Generating project file using SwiftPM and config file $xcconfigFile"
    swift package generate-xcodeproj --xcconfig-overrides $xcconfigFile

    # NOTE: the xcconfig file will be applied to all dependency targets as well,
    # but it's not an issue for in this case.

    echo "Overriding PRODUCT_BUNDLE_IDENTIFIER with <$bundleId> in project file due to bug in SwiftPM."
    # SwiftPM overrides this value even after applying custom xcconfig file.
    sed -i '' -e "s|PRODUCT_BUNDLE_IDENTIFIER = \\"$productName\\"|PRODUCT_BUNDLE_IDENTIFIER = $bundleId|g" $productName.xcodeproj/project.pbxproj

    echo "ℹ️ Done"
    
    """
    )
    .prepare(
        at: [prepareForCarthageShFileName]
    )
    .writeToFileSystem()

// MARK: - POST-script invocation output

print("--- END of '\(Executable.name)' script ---")

// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Variants",
    platforms: [
           .macOS(.v10_15)
    ],
    products: [
        .executable(name: "variants", targets: ["Variants"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/kylef/PathKit",
            from: "1.0.1"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "5.0.0"
        ),
        .package(
            name: "XcodeProj",
            url: "https://github.com/tuist/xcodeproj.git",
            from: "8.3.1"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/stencilproject/Stencil.git",
            from: "0.13.0"
        ),
        .package(
            name: "danger-swift",
            url: "https://github.com/danger/swift.git",
            from: "3.5.0"
        ),
        .package(
            url: "https://github.com/realm/SwiftLint",
            from: "0.58.0"
        )
    ],
    targets: [
        .target(
            name: "VariantsCore",
            dependencies: [
                "PathKit",
                "Yams",
                "XcodeProj",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Stencil"
            ]
        ),
        .target(
            name: "Variants",
            dependencies: [
                "VariantsCore"
            ]
        ),
        .testTarget(
            name: "VariantsTests",
            dependencies: [
                "Variants"
            ]
        )
    ]
)

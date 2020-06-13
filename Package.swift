// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Variants",
    products: [
        .executable(name: "variants", targets: ["Variants"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/kylef/PathKit",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "2.0.0"
        ),
        .package(
            name: "XcodeProj",
            url: "https://github.com/tuist/xcodeproj.git",
            from: "7.11.1"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "Variants",
            dependencies: [
                "PathKit",
                "Yams",
                "XcodeProj",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "VariantsTests",
            dependencies: ["Variants"]
        ),
    ]
)

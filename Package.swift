// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Variants",
    products: [
        .executable(name: "variants", targets: ["Variants"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/jakeheis/SwiftCLI",
            from: "6.0.0"
        ),
        .package(
            url: "https://github.com/kylef/PathKit",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "Variants",
            dependencies: [
                "SwiftCLI",
                "PathKit",
                "Yams"
            ]
        ),
        .testTarget(
            name: "VariantsTests",
            dependencies: ["Variants"]
        ),
    ]
)

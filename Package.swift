// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MobileSetup",
    products: [
        .executable(name: "mobile-setup", targets: ["MobileSetup"])
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
            name: "MobileSetup",
            dependencies: [
                "SwiftCLI",
                "PathKit",
                "Yams"
            ]
        ),
        .testTarget(
            name: "MobileSetupTests",
            dependencies: ["MobileSetup"]
        ),
    ]
)

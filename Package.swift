// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Variants",
    products: [
        .executable(name: "variants", targets: ["Variants"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Variants",
            dependencies: [
                "VariantsCore"
            ]
        ),
        .testTarget(
            name: "VariantsTests",
            dependencies: ["Variants"]
        ),
    ]
)

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyanmarHome",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MyanmarHomeCommon",
            targets: ["MyanmarHomeCommon"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    ],
    targets: [
        .target(
            name: "MyanmarHomeCommon",
            dependencies: [
                "Alamofire",
            ],
            path: "Common"
        ),
        .testTarget(
            name: "MyanmarHomeTests",
            dependencies: ["MyanmarHomeCommon"],
            path: "Tests"
        ),
    ]
)

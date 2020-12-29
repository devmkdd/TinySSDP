// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinySSDP",
    platforms: [
        SupportedPlatform.iOS(.v11),
        SupportedPlatform.macOS(.v10_14)
        
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TinySSDP",
            targets: ["TinySSDP"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Socket", url: "https://github.com/Kitura/BlueSocket.git", .exact("1.0.52"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TinySSDP",
            dependencies: ["Socket"]),
        .testTarget(
            name: "TinySSDPTests",
            dependencies: ["TinySSDP"]),
    ]
)


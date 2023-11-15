// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TidSocialSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "TidSocialSDK", targets: ["TidSocialLib"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.18.2"),
        //.package(path: "../tid-ios-sdk")
        .package(url: "https://github.com/t-id/tid-ios-sdk", from: "2.4.2"),
    ],
    targets: [
        .target(
            name: "TidSocialLib",
            dependencies: [
                .product(name: "TidSDK", package: "tid-ios-sdk"),
                "NaverThirdPartyLoginFramework",
                .product(name: "KakaoSDKCommon", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKAuth", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKUser", package: "kakao-ios-sdk"),
            ]
        ),
        .binaryTarget(
            name: "NaverThirdPartyLoginFramework",
            path: "./Frameworks/NaverThirdPartyLogin.xcframework"
        ),
    ]
)

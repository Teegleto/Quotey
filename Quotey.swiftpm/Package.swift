// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Quotey",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Quotey",
            targets: ["AppModule"],
            bundleIdentifier: "com.quotey.playground",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .books),
            accentColor: .presetColor(.purple),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "Quotey uses the camera to scan text from pages so you can capture quotes without typing."),
                .photoLibrary(purposeString: "Quotey reads text from photos of pages so you can capture quotes without typing.")
            ],
            appCategory: .productivity
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)

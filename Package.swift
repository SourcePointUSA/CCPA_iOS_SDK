// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "CCPAConsentViewController",
  platforms: [
    .iOS(.v10)
  ],
  products: [
    .library(
      name: "CCPAConsentViewController",
      targets: ["CCPAConsentViewController"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "CCPAConsentViewController",
      dependencies: [],
      path: "CCPAConsentViewController",
      resources: [
        .process("Assets/JSReceiver.js")
      ]
    )
  ],
  swiftLanguageVersions: [.v5]
)

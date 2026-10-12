# Progetti Xcode generati da XcodeGen, fuori da git

Ogni **App Sbu** è descritta da un `project.yml` e il `.xcodeproj` si rigenera con `xcodegen generate` (lo fanno anche `new_app.sh` e ogni lane fastlane); il `.xcodeproj` non è versionato. Con molte app quasi uguali, un file YAML leggibile nei diff e creato da un template batte un `.pbxproj` da centinaia di righe. Tuist era l'alternativa: più potente, ma porta un suo runtime, una cache e un manifest in Swift per un bisogno che XcodeGen già copre.

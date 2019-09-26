#!/bin/bash
# http://www.grymoire.com/Unix/Sed.html#TOC

currentVersion=$1

#---

productName="XCEUniFlow"
bundleId="com.XCEssentials.UniFlow"

xcconfigFile="PrepareForCarthage.xcconfig"

#---

echo "ℹ️ Preparing $productName for Carthage."

echo "Updating xcconfig file with version $currentVersion..."
sed -i '' -e "s|^CURRENT_PROJECT_VERSION = .*$|CURRENT_PROJECT_VERSION = $currentVersion|g" $xcconfigFile

echo "Generating project file using SwiftPM and config file $xcconfigFile"
swift package generate-xcodeproj --xcconfig-overrides $xcconfigFile

# NOTE: the xcconfig file will be applied to all dependency targets as well,
# but it's not an issue for in this case.

echo "Overriding PRODUCT_BUNDLE_IDENTIFIER with <$bundleId> in project file due to bug in SwiftPM."
# SwiftPM overrides this value even after applying custom xcconfig file.
sed -i '' -e "s|PRODUCT_BUNDLE_IDENTIFIER = \"$productName\"|PRODUCT_BUNDLE_IDENTIFIER = $bundleId|g" $productName.xcodeproj/project.pbxproj

echo "ℹ️ Done"

#!/bin/bash

# http://www.grymoire.com/Unix/Sed.html#TOC
sed -i '' -e "s|PRODUCT_BUNDLE_IDENTIFIER = \"XCEUniFlow\"|PRODUCT_BUNDLE_IDENTIFIER = com.XCEssentials.UniFlow|g" XCEUniFlow.xcodeproj/project.pbxproj

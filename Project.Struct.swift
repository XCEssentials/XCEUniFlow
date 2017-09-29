import XCEProjectGenerator

//===

let params =
(
    repoName: "UniFlow",
    deploymentTarget: "8.0",
    companyIdentifier: "io.XCEssentials",
    companyPrefix: "XCE"
)

let bundleId =
(
    fwk: "\(params.companyIdentifier).\(params.repoName)",
    tst: "\(params.companyIdentifier).\(params.repoName).Tst"
)

//===

let specFormat = Spec.Format.v2_1_0

let project = Project("Main") { project in
    
    project.configurations.all.override(
        
        "IPHONEOS_DEPLOYMENT_TARGET" <<< params.deploymentTarget, // bug wokraround
        
        "SWIFT_VERSION" <<< "3.0",
        "VERSIONING_SYSTEM" <<< "apple-generic",
        
        "CURRENT_PROJECT_VERSION" <<< "0" // just a default non-empty value
    )
    
    project.configurations.debug.override(
        
        "SWIFT_OPTIMIZATION_LEVEL" <<< "-Onone"
    )
    
    //---
    
    project.target("Fwk", .iOS, .framework) { target in
        
        target.include("Sources")
        
        //---
        
        target.configurations.all.override(
            
            "PRODUCT_NAME" <<< "\(params.companyPrefix)\(params.repoName)",
            
            "IPHONEOS_DEPLOYMENT_TARGET" <<< params.deploymentTarget, // bug wokraround
        
            "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.fwk,
            "INFOPLIST_FILE" <<< "Info/Fwk.plist",

            "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES" <<< "$(inherited)",
            
            //--- iOS related:
            
            "SDKROOT" <<< "iphoneos",
            "TARGETED_DEVICE_FAMILY" <<< DeviceFamily.iOS.universal,
            
            //--- Framework related:
            
            "DEFINES_MODULE" <<< "NO",
            "SKIP_INSTALL" <<< "YES"
        )
        
        target.configurations.debug.override(
            
            "MTL_ENABLE_DEBUG_INFO" <<< true
        )
        
        //---
    
        target.unitTests { unitTests in
            
            unitTests.include("Tests")
            
            //---
            
            unitTests.configurations.all.override(

                "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES" <<< "$(inherited)",
                
                // very important for unit tests,
                // prevents the error when unit test do not start at all
                "LD_RUNPATH_SEARCH_PATHS" <<<
                "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",
                
                "IPHONEOS_DEPLOYMENT_TARGET" <<< params.deploymentTarget, // bug wokraround
                
                "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst,
                "INFOPLIST_FILE" <<< "Info/Tst.plist",
                "FRAMEWORK_SEARCH_PATHS" <<< "$(inherited) $(BUILT_PRODUCTS_DIR)"
            )
            
            unitTests.configurations.debug.override(
                
                "MTL_ENABLE_DEBUG_INFO" <<< true
            )
        }
    }
}

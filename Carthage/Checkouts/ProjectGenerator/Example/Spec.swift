import XCEProjectGenerator

//===

let params =
(
    repoName: "MyAwesomeFramework",
    deploymentTarget: "8.0",
    companyIdentifier: "khatskevich.maxim",
    developmentTeamId: "UJA88X59XP" // 'Maxim Khatskevich'
)

let bundleId =
(
    fwk: "\(params.companyIdentifier).\(params.repoName)",
    tst: "\(params.companyIdentifier).\(params.repoName).Tst"
)

//===

let specFormat = Spec.Format.v2_1_0

let project = Project(params.repoName) { project in
    
    project.configurations.all.override(
        
        "IPHONEOS_DEPLOYMENT_TARGET" <<< params.deploymentTarget, // bug wokraround
        
        "DEVELOPMENT_TEAM" <<< params.developmentTeamId,
        
        "SWIFT_VERSION" <<< "3.0",
        "VERSIONING_SYSTEM" <<< "apple-generic"
    )
    
    project.configurations.debug.override(
        
        "SWIFT_OPTIMIZATION_LEVEL" <<< "-Onone"
    )
    
    //---
    
    project.target("App", .iOS, .framework) { app in
        
        app.include("Src")
        
        //---
        
        app.configurations.all.override(
            
            "IPHONEOS_DEPLOYMENT_TARGET" <<< params.deploymentTarget, // bug wokraround
        
            "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.fwk,
            "INFOPLIST_FILE" <<< "Info/Fwk.plist",
            
            //--- iOS related:
            
            "SDKROOT" <<< "iphoneos",
            "TARGETED_DEVICE_FAMILY" <<< DeviceFamily.iOS.universal,
            
            //--- Framework related:
            
            "DEFINES_MODULE" <<< "NO",
            "SKIP_INSTALL" <<< "YES"
        )
        
        app.configurations.debug.override(
            
            "MTL_ENABLE_DEBUG_INFO" <<< true
        )
        
        //---
    
        app.unitTests { appTests in
            
            appTests.include("Tst")
            
            //---
            
            appTests.configurations.all.override(
                
                // very important for unit tests,
                // prevents the error when unit test do not start at all
                "LD_RUNPATH_SEARCH_PATHS" <<<
                "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",
                
                "IPHONEOS_DEPLOYMENT_TARGET" <<< params.deploymentTarget, // bug wokraround
                
                "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.tst,
                "INFOPLIST_FILE" <<< "Info/Tst.plist",
                "FRAMEWORK_SEARCH_PATHS" <<< "$(inherited) $(BUILT_PRODUCTS_DIR)"
            )
            
            appTests.configurations.debug.override(
                
                "MTL_ENABLE_DEBUG_INFO" <<< true
            )
        }
    }
}

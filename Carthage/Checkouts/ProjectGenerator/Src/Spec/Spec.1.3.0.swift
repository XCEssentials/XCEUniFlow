import Foundation

//===

enum Spec_1_3_0
{
    static
    func generate(for p: Project) -> RawSpec
    {
        var result: RawSpec = []
        var idention: Int = 0
        
        //===
        
        result <<< (idention, "# generated with MKHProjGen")
        result <<< (idention, "# https://github.com/maximkhatskevich/MKHProjGen")
        result <<< (idention, "# https://github.com/workshop/struct/wiki/Spec-format:-v1.3")
        
        //===
        
        // https://github.com/workshop/struct/wiki/Spec-format:-v1.3#version-number
        
        result <<< (idention, Spec.key("version") + " \(Spec.Format.v1_3_0.rawValue)")
        
        //===
        
        result <<< process(&idention, p.configurations)
        
        //===
        
        result <<< process(&idention, p.targets)
        
        //===
        
        result <<< (idention, Spec.key("variants"))
        
        idention += 1
        
        result <<< (idention, Spec.key("$base"))
        
        idention += 1
        
        result <<< (idention, Spec.key("abstract") + " true")
        
        idention -= 1
        
        result <<< (idention, Spec.key(p.name))
        
        idention -= 1
        
        //===
        
        result <<< (0, "") // empty line in the EOF
        
        //===
        
        return result
    }
    
    //===
    
    static
    func process(
        _ idention: inout Int,
        _ set: Project.BuildConfigurations
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#configurations
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        result <<< (idention, Spec.key("configurations"))
        
        //===
        
        idention += 1
        
        //===
        
        result <<< process(&idention, set.all, set.debug)
        result <<< process(&idention, set.all, set.release)
        
        //===
        
        idention -= 1
        
        //===
        
        return result
    }
    
    //===
    
    static
    func process(
        _ idention: inout Int,
        _ b: Project.BuildConfiguration.Base,
        _ c: Project.BuildConfiguration
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#configurations
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        result <<< (idention, Spec.key(c.name))
        
        //===
        
        idention += 1
        
        //===
        
        result <<< (idention, Spec.key("type") + Spec.value(c.type))
        
        //===
        
        if
            let externalConfig = c.externalConfig
        {
            // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#xcconfig-references
            
            // NOTE: when using xcconfig files,
            // any overrides or profiles will be ignored.
            
            result <<< (idention, Spec.key("source") + Spec.value(externalConfig) )
        }
        else
        {
            // NO source/xcconfig provided
            
            //===
            
            // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#profiles
            
            result <<< (idention, Spec.key("profiles"))
            
            for p in b.profiles + c.profiles
            {
                result <<< (idention, "-" + Spec.value(p))
            }
            
            //===
            
            // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#overrides
            
            result <<< (idention, Spec.key("overrides"))
            idention += 1
            
            for o in b.overrides + c.overrides
            {
                result <<< (idention, Spec.key(o.key) + Spec.value(o.value))
            }
            
            idention -= 1
        }
        
        //===
        
        idention -= 1
        
        //===
        
        return result
    }
    
    //===
    
    static
    func process(
        _ idention: inout Int,
        _ targets: [Project.Target]
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#targets
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        result <<< (idention, Spec.key("targets"))
        
        //===
        
        idention += 1
        
        //===
        
        for t in targets
        {
            result <<< process(&idention, t)
            
            //===
            
            for tst in t.tests
            {
                result <<< process(&idention, tst)
            }
        }
        
        //===
        
        idention -= 1
        
        //===
        
        return result
    }
    
    //===
    
    static
    func process(
        _ idention: inout Int,
        _ t: Project.Target
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#targets
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        result <<< (idention, Spec.key(t.name))
        
        //===
        
        idention += 1
        
        //===
        
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#platform
        
        result <<< (idention, Spec.key("platform") + Spec.value(t.platform.rawValue))
        
        //===
        
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#type
        
        result <<< (idention, Spec.key("type") + Spec.value(t.type.rawValue))
        
        //===
        
        result <<< process(&idention, t.dependencies)
        
        //===
        
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#sources
        
        if
            !t.includes.isEmpty
        {
            result <<< (idention, "sources:")
            
            for path in t.includes
            {
                result <<< (idention, "-" + Spec.value(path))
            }
        }
        
        //===
        
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#excludes
        
        if
            !t.excludes.isEmpty
        {
            result <<< (idention, Spec.key("excludes"))
            idention += 1
            result <<< (idention, Spec.key("files"))
            
            for path in t.excludes
            {
                result <<< (idention, "-" + Spec.value(path))
            }
            
            idention -= 1
        }
        
        //===
        
        // https://github.com/workshop/struct/wiki/Spec-format:-v1.3#options
        
        if
            !t.sourceOptions.isEmpty
        {
            result <<< (idention, "source_options:")
            idention += 1
            
            for (path, opt) in t.sourceOptions
            {
                result <<< (idention, Spec.key(path) + Spec.value(opt))
            }
            
            idention -= 1
        }
        
        //===
        
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#i18n-resources
        
        if
            !t.i18nResources.isEmpty
        {
            result <<< (idention, Spec.key("i18n-resources"))
            
            for path in t.i18nResources
            {
                result <<< (idention, "-" + Spec.value(path))
            }
        }
        
        //===
        
        result <<< process(&idention, t.configurations)
        
        //===
        
        result <<< process(&idention, scripts: t.scripts)
        
        //===
        
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#cocoapods
        
        if
            t.includeCocoapods
        {
            result <<<
                (idention,
                 Spec.key("includes_cocoapods") + Spec.value(t.includeCocoapods))
        }
        
        //===
        
        idention -= 1
        
        //===
        
        return result
    }
    
    //===
    
    static
    func process(
        _ idention: inout Int,
        _ deps: Project.Target.Dependencies
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#references
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        if
            !deps.fromSDKs.isEmpty ||
            !deps.otherTargets.isEmpty ||
            !deps.binaries.isEmpty ||
            !deps.projects.isEmpty
        {
            result <<< (idention, Spec.key("references"))
            
            //===
            
            result <<< processDependencies(&idention, fromSDK: deps.fromSDKs)
            result <<< processDependencies(&idention, targets: deps.otherTargets)
            result <<< processDependencies(&idention, binaries: deps.binaries)
            result <<< processDependencies(&idention, projects: deps.projects)
        }
        
        //===
        
        return result
    }
    
    //===
    
    static
    func processDependencies(
        _ idention: inout Int,
        fromSDK: [String]
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#references
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        for dep in fromSDK
        {
            result <<< (idention, "-" + Spec.value("sdkroot:\(dep)"))
        }
        
        //===
        
        return result
    }
    
    //===
    
    static
    func processDependencies(
        _ idention: inout Int,
        targets: [String]
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#references
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        for t in targets
        {
            result <<< (idention, "-" + Spec.value(t))
        }
        
        //===
        
        return result
    }
    
    //===
    
    static
    func processDependencies(
        _ idention: inout Int,
        binaries: [Project.Target.BinaryDependency]
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#references
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        for b in binaries
        {
            result <<< (idention, Spec.key("- location") + Spec.value(b.location))
            result <<< (idention, Spec.key("  codeSignOnCopy") + Spec.value(b.codeSignOnCopy))
        }
        
        //===
        
        return result
    }
    
    //===
    
    static
    func processDependencies(
        _ idention: inout Int,
        projects: [Project.Target.ProjectDependencies]
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#references
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        for p in projects
        {
            result <<< (idention, Spec.key("- location") + Spec.value(p.location))
            result <<< (idention, Spec.key("  frameworks"))
            
            for f in p.frameworks
            {
                result <<< (idention, Spec.key("  - name") + Spec.value(f.name))
                result <<< (idention, Spec.key("    copy") + Spec.value(f.copy))
                result <<< (idention, Spec.key("    codeSignOnCopy") + Spec.value(f.codeSignOnCopy))
            }
        }
        
        //===
        
        return result
    }
    
    //===
    
    static
    func process(
        _ idention: inout Int,
        _ set: Project.Target.BuildConfigurations
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/issues/77#issuecomment-287573381
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        result <<< (idention, Spec.key("configurations"))
        
        //===
        
        idention += 1
        
        //===
        
        result <<< process(&idention, set.all, set.debug)
        result <<< process(&idention, set.all, set.release)
        
        //===
        
        idention -= 1
        
        //===
        
        return result
    }
    
    //===
    
    static
    func process(
        _ idention: inout Int,
        _ b: Project.Target.BuildConfiguration.Base,
        _ c: Project.Target.BuildConfiguration
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/issues/77#issuecomment-287573381
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        result <<< (idention, Spec.key(c.name))
        
        //===
        
        idention += 1
        
        //===
        
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#overrides
        
        for o in b.overrides + c.overrides
        {
            result <<< (idention, Spec.key(o.key) + Spec.value(o.value))
        }
        
        //===
        
        idention -= 1
        
        //===
        
        return result
    }
    
    //===
    
    static
    func process(
        _ idention: inout Int,
        scripts: Project.Target.Scripts
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#scripts
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        if
            !scripts.regulars.isEmpty ||
            !scripts.beforeBuilds.isEmpty ||
            !scripts.afterBuilds.isEmpty
        {
            result <<< (idention, Spec.key("scripts"))
            
            //===
            
            idention += 1
            
            //===
            
            if
                !scripts.regulars.isEmpty
            {
                result <<< processScripts(&idention, regulars: scripts.regulars)
            }
            
            if
                !scripts.beforeBuilds.isEmpty
            {
                result <<< processScripts(&idention, beforeBuild: scripts.beforeBuilds)
            }
            
            if
                !scripts.afterBuilds.isEmpty
            {
                result <<< processScripts(&idention, afterBuild: scripts.afterBuilds)
            }
            
            //===
            
            idention -= 1
        }
        
        //===
        
        return result
    }
    
    //===
    
    static
    func processScripts(
        _ idention: inout Int,
        regulars: [String]
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#scripts
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        for s in regulars
        {
            result <<< (idention, "-" + Spec.value(s))
        }
        
        //===
        
        return result
    }
    
    //===
    
    static
    func processScripts(
        _ idention: inout Int,
        beforeBuild: [String]
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#scripts
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        result <<< (idention, Spec.key("prebuild"))
        
        for s in beforeBuild
        {
            result <<< (idention, "-" + Spec.value(s))
        }
        
        //===
        
        return result
    }
    
    //===
    
    static
    func processScripts(
        _ idention: inout Int,
        afterBuild: [String]
        ) -> RawSpec
    {
        // https://github.com/lyptt/struct/wiki/Spec-format:-v1.2#scripts
        
        //===
        
        var result: RawSpec = []
        
        //===
        
        result <<< (idention, Spec.key("postbuild"))
        
        for s in afterBuild
        {
            result <<< (idention, "-" + Spec.value(s))
        }
        
        //===
        
        return result
    }
}

projFileName = ARGV[0]
fullProjFilePath = Dir.pwd + '/' + ARGV[0]

#===

require 'xcodeproj'
project = Xcodeproj::Project.open(fullProjFilePath)
mainTarget = project.targets.first

# === SwiftLint

swiftLintPhase = mainTarget.new_shell_script_build_phase("SwiftLint")
swiftLintPhase.shell_script = 'if which swiftlint >/dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi'
# swiftLintPhase.run_only_for_deployment_postprocessing = '1'

mainTarget.build_phases.delete(swiftLintPhase)
mainTarget.build_phases.unshift(swiftLintPhase)

# ===

project.save()
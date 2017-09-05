repoName = 'UniFlow'
projName = 'Main'

platform :ios, '8.0'

workspace repoName

use_frameworks!

#===

def sharedPods

	pod 'XCERequirement', '~> 1.4'
	pod 'XCEByTypeStorage', '~> 1.1'

end

#===

target 'Fwk' do

	project projName

	#===

	sharedPods

end

target 'Tests' do

	project projName

	#===

	sharedPods

    #===
    
    pod 'XCETesting', '~> 1.1'

end




projName = 'UniFlow'
projSummary = 'App architecture done right, inspired by Flux (from Facebook).'
companyPrefix = 'XCE'
companyName = 'XCEssentials'
companyGitHubAccount = 'https://github.com/' + companyName
companyGitHubPage = 'https://' + companyName + '.github.io'

#===

Pod::Spec.new do |s|

  s.name                      = companyPrefix + projName
  s.summary                   = projSummary
  s.version                   = '4.7.0'
  s.homepage                  = companyGitHubPage + '/' + projName
  
  s.source                    = { :git => companyGitHubAccount + '/' + projName + '.git', :tag => s.version }

  s.ios.deployment_target     = '9.0'
  s.osx.deployment_target     = '10.11'
  s.tvos.deployment_target    = '11.0'
  s.watchos.deployment_target = '4.0'
  
  s.requires_arc              = true
  
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|

    ss.dependency               'XCERequirement', '~> 1.6'

    ss.source_files           = 'Sources/Core/**/*.swift'

  end

  s.subspec 'MVVM' do |ss|

    ss.dependency               s.name + '/Core'
  
    ss.source_files           = 'Sources/MVVM/**/*.swift'

  end

end

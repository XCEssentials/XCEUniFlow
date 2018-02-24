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
  s.version                   = '4.10.1'
  s.homepage                  = companyGitHubPage + '/' + projName
  
  s.source                    = { :git => companyGitHubAccount + '/' + projName + '.git', :tag => s.version }

  s.ios.deployment_target     = '9.0'
  s.osx.deployment_target     = '10.11'
  s.tvos.deployment_target    = '11.0'
  s.watchos.deployment_target = '4.0'
  
  s.requires_arc              = true
  
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }

  s.dependency                  'XCERequirement', '~> 1.6'

  s.source_files              = 'Sources/**/*.swift'

end

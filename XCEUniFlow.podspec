Pod::Spec.new do |s|

  s.name                      = 'XCEUniFlow'
  s.summary                   = 'App architecture done right, inspired by Flux (from Facebook).'
  s.version                   = '3.2.0'
  s.homepage                  = 'https://XCEssentials.github.io//UniFlow'
  
  s.source                    = { :git => 'https://github.com/XCEssentials/UniFlow.git', :tag => '#{s.version}' }
  s.source_files              = 'Src/**/*.swift'

  s.ios.deployment_target     = '8.0'
  s.requires_arc              = true
  
  s.dependency                  'MKHRequirement', '~> 1.1'

  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }
  s.social_media_url          = 'http://www.linkedin.com/in/maximkhatskevich'

end

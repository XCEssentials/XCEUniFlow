Pod::Spec.new do |s|

  s.name                      = 'MKHUniFlow'
  s.version                   = '1.1.1'
  s.summary                   = 'Unidirectional data flow manager (state machine) for Cocoa'
  s.homepage                  = 'https://github.com/maximkhatskevich/#{s.name}'
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }
  s.ios.deployment_target     = '8.0'
  s.source                    = { :git => '#{s.homepage}.git', :tag => '#{s.version}' }
  s.ios.source_files          = 'Src/Common/*.swift', 'Src/iOS/*.swift'
  s.requires_arc              = true
  s.social_media_url          = 'http://www.linkedin.com/in/maximkhatskevich'

end

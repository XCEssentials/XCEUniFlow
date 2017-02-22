Pod::Spec.new do |s|

  s.name                      = 'MKHUniFlow'
  s.version                   = '3.1.0'
  s.summary                   = 'Unidirectional data flow manager (state machine) for Cocoa and Cocoa Touch.'
  s.homepage                  = 'https://github.com/maximkhatskevich/#{s.name}'
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.author                    = { 'Maxim Khatskevich' => 'maxim@khatskevi.ch' }
  s.ios.deployment_target     = '8.0'
  s.source                    = { :git => '#{s.homepage}.git', :tag => '#{s.version}' }
  s.source_files              = 'Src/**/*.swift'
  s.requires_arc              = true
  s.social_media_url          = 'http://www.linkedin.com/in/maximkhatskevich'

end

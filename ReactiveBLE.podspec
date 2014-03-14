Pod::Spec.new do |s|
  s.name         = "ReactiveBLE"
  s.version      = "0.0.1"
  s.summary      = "Reactive Bluetooth LE."

  s.description  = <<-DESC
                   Reactive Bluetooth LE
                   DESC

  s.homepage     = "https://github.com/eliperkins/ReactiveBLE"
  s.license      = 'MIT'
  s.author             = { "Eli Perkins" => "eli@onemightyroar.com" }
  # s.authors          = { "Eli Perkins" => "eli@onemightyroar.com", "other author" => "email@address.com" }
  s.source       = { :git => "https://github.com/eliperkins/ReactiveBLE.git", :commit => "b49ab423e9593e9befc2e191d12d03bc74f0e9b5" }
  s.source_files  = 'ReactiveBLE', 'ReactiveBLE/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "10.7"
  s.ios.framework    = 'CoreBluetooth'
  s.osx.framework    = 'IOBluetooth'
  s.dependency 'ReactiveCocoa'
  s.dependency 'libextobjc/EXTScope'
end

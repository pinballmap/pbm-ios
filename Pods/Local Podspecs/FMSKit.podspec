Pod::Spec.new do |s|
  s.name             = "FMSKit"
  s.version          = "0.3.2"
  s.summary          = "Collection of helpful categories and classes for iOS app development"
  s.description      = <<-DESC
                        A set of helpful objective C categories and a handful of classes. Includes FMSDrawer a drawer UI element. View
                        README for information on how to use categories and FMSDrawer.
                       DESC
  s.homepage         = "http://github.com/fmscode"
  s.license          = 'MIT'
  s.author           = { "Frank Michael Sanchez" => "orion1701@me.com" }
  s.source           = { :git => "https://github.com/fmscode/FMSKit.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'ios/*.{h,m}'
  s.resources = 'Assets/*'

end

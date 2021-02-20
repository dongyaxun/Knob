Pod::Spec.new do |spec|
  spec.name         = "Knob"
  spec.version      = "0.0.1"
  spec.summary      = "Knob UI Control in Swift."
  spec.homepage     = "https://github.com/dongyaxun/Knob"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "dongyaxun" => "dyx_1991@icloud.com" }
  spec.platform     = :ios, "10.0"
  spec.swift_versions = ["5.0", "5.1", "5.2", "5.3"]
  spec.source       = { :git => "https://github.com/dongyaxun/Knob.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/*/*.swift"
end

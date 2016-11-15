
Pod::Spec.new do |s|

  s.name             = "Jiffy"
  s.version          = "1.0.0"
  s.summary          = "Easy animated images for Swift!"
  s.description      = <<-DESC
    Jiffy makes working with animated images (.gif / .apng) a breeze.
    While there are a lot of libraries out there that
    accomplish something similar, most of them are usually
    plagued with un-needed features and performance issues.
    Jiffy aims to be a small & simple animated image
    library with little-to-no performance overhead.
    DESC
  s.homepage         = "https://github.com/mitchtreece/Jiffy"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Mitch Treece" => "mitchtreece@me.com" }
  s.source           = { :git => "https://github.com/mitchtreece/Jiffy.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MitchTreece'

  s.platform         = :ios, "9.0"
  s.source_files     = 'Jiffy/Classes/**/*'

end

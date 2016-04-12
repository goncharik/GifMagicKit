Pod::Spec.new do |spec|
  spec.name = "GifMagicKit"
  spec.version = "0.1.0"
  spec.summary = "GifMagicKit is a Library for converting videos and live photos into animated GIFs"
  spec.description  = <<-DESC
                        Simple and light weight library for converting videos and live photos into animated GIFs
                    DESC
  spec.homepage = "https://github.com/alokard/GifMagicKit"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Eugene Tulusha" => 'tulusheg@gmail.com' }
  spec.social_media_url = "http://twitter.com/alokard"

  spec.platform = :ios
  spec.platform = :osx
  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.9"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/alokard/GifMagicKit.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "Sources/**/*.{h,swift}"

end
Pod::Spec.new do |spec|
  spec.name = "GifMagicKit"
  spec.version = "1.0.0"
  spec.summary = "GifMagicKit is a Library for converting videos and live photos into animated GIFs"
  spec.homepage = "https://github.com/alokard/GifMagicKit"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Eugene Tulusha" => 'tulusheg@gmail.com' }
  spec.social_media_url = "http://twitter.com/alokard"

  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/alokard/GifMagicKit.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "GifMagicKit/**/*.{h,swift}"

end
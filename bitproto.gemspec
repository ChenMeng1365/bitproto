
Gem::Specification.new do |spec|
  spec.name          = "bit-protocol"
  spec.version       = '1.0.1'
  spec.authors       = ["Matt"]
  spec.email         = ["matthrewchains@gmail.com","18995691365@189.cn"]
  spec.license       = "AGPL-3.0"

  spec.summary       = %q{bitproto}
  spec.description   = %q{bit operating, destructuring, and encoding}
  spec.homepage      = %q{https://github.com/ChenMeng1365/network}
  spec.files         = [
    'bitop',
    'bitstream',
    'bitproto'
  ].map{|file|"#{file}.rb"} + Dir["document/*"] + ["README.md", "LICENSE", "GEMFILE"]

  # spec.bindir        = ""
  # spec.executables   = [""]
  spec.require_paths = ["."]
  spec.add_runtime_dependency 'cc',  "~> 1.1.1"
  spec.add_runtime_dependency 'casetdown', "~> 0.9.0"
end

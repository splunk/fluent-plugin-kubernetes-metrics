lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-kubernetes-metrics"
  spec.version = "1.0.0"
  spec.authors = ["Gimi Liang"]
  spec.email   = ["zliang@splunk.com"]

  spec.summary       = %q{A fluentd input plugin that collects kubernetes cluster metrics.}
  spec.description   = %q{A fluentd input plugin that collects node and container metrics from a kubernetes cluster via summary API.}
  spec.homepage      = "https://github.com/splunk/fluent-plugin-kubernetes-metrics"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_runtime_dependency "kubeclient", "~> 4.0"
  spec.add_runtime_dependency "multi_json", "~> 1.13"
  spec.add_runtime_dependency "oj", "~> 3.6"
end

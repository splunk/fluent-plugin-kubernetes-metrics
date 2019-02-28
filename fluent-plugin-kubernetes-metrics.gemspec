lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-kubernetes-metrics"
  spec.version = File.read('VERSION')
  spec.authors = ["Splunk Inc."]
  spec.email   = ["DataEdge@splunk.com"]
  spec.summary       = %q{A fluentd input plugin that collects kubernetes cluster metrics.}
  spec.description   = %q{A fluentd input plugin that collects node and container metrics from a kubernetes cluster.}
  spec.homepage      = "https://github.com/splunk/fluent-plugin-kubernetes-metrics"
  spec.license       = "Apache-2.0"
  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 2.0.1"
  spec.add_development_dependency "rake", "~> 12.3.2"
  spec.add_development_dependency "test-unit", "~> 3.3.0"
  spec.add_development_dependency "simplecov", "~> 0.16.1"
  spec.add_development_dependency "webmock", "~> 3.5.1"
  spec.add_runtime_dependency "fluentd", "~> 1.3.3"
  spec.add_runtime_dependency "kubeclient", "~> 4.2.2"
  spec.add_runtime_dependency "multi_json", "~> 1.13.1"
  spec.add_runtime_dependency "oj", "~> 3.7.8"
end
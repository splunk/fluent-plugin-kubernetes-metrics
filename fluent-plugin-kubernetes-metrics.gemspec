lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = 'fluent-plugin-kubernetes-metrics'
  spec.version = File.read('VERSION')
  spec.authors = ['Splunk Inc.']
  spec.email   = ['DataEdge@splunk.com']
  spec.summary       = 'A fluentd input plugin that collects kubernetes cluster metrics.'
  spec.description   = 'A fluentd input plugin that collects node and container metrics from a kubernetes cluster.'
  spec.homepage      = 'https://github.com/splunk/fluent-plugin-kubernetes-metrics'
  spec.license       = 'Apache-2.0'
  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ['lib']
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'test-unit', '~> 3.3.0'
  spec.add_development_dependency 'webmock', '~> 3.5.1'
  spec.add_runtime_dependency 'fluentd', '~> 1.9.1'
  spec.add_runtime_dependency 'kubeclient', '~> 4.6.0'
  spec.add_runtime_dependency 'multi_json', '~> 1.14.1'
  spec.add_runtime_dependency 'oj', '~> 3.10.2'
end

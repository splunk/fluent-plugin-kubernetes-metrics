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

  spec.files         = %w[
    metrics-information.md README.md LICENSE
    fluent-plugin-kubernetes-metrics.gemspec
    Gemfile Gemfile.lock
    Rakefile VERSION
  ] + Dir.glob('lib/**/**').reject(&File.method(:directory?))
  spec.test_files    = Dir.glob('test/**/**.rb')
  spec.require_paths = ['lib']
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'test-unit', '~> 3.3.0'
  spec.add_development_dependency 'webmock', '~> 3.5.1'
  spec.add_runtime_dependency 'fluentd', '>= 1.9.1'
  spec.add_runtime_dependency 'kubeclient', '~> 4.9.3'
  spec.add_runtime_dependency 'multi_json', '~> 1.14'
  spec.add_runtime_dependency 'oj', '~> 3.10'
end

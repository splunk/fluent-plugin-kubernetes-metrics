require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
require 'rake/clean'

CLEAN.concat FileList[
  'docker/*.gem',
  'pkg'
]

Rake::TestTask.new(:test) do |t|
  t.libs.push('lib', 'test')
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
  t.warning = false
end

task default: [:test]

namespace :docker do
  desc 'Build docker image'
  task :build, [:tag] => :build do |_t, args|
    raise 'Argument `tag` was not provided.' unless args.tag

    sh "docker build --build-arg VERSION=$(cat VERSION) --no-cache -t splunk/connect-for-kubernetes:#{args.tag} -f docker/Dockerfile ."
  end
end

require 'rake'
require 'rspec/core/rake_task'
require 'yaml'

task :default => [:help]

desc 'Check if we are not working in master'
task :check_branch do
  fail "You must work in a branch other than master." unless ENV['nocheck'] or ENV['nocheck_branch'] or `git rev-parse --abbrev-ref HEAD`.strip != 'master'
end

desc 'Check if working directory is clean'
task :check_git_status do
  if !ENV['nocheck'] and !ENV['nocheck_git_status']
    fail "You have unstaged changes." unless system("git diff --exit-code")
    fail "You have changes that are staged but not committed." unless system("git diff --cached --exit-code")
    fail "You have untracked files." unless system("git ls-files --other --exclude-standard --directory")
  end
end

desc 'Check if gem version is explicitely set'
task :check_gem_version do
  puts 'TODO: Check if gem version is explicitely set' unless ENV['nocheck'] or ENV['nocheck_gem_version']
end

desc 'Check if all dependency version is explicitely set'
task :check_deps_version do
  if !ENV['nocheck'] and !ENV['nocheck_deps_version']
    fixtures = YAML.load_file('.fixtures.yml')
    fixtures['fixtures']['repositories'].select do |k, v|
      fail "You must explicitely set a tag ref for module #{k} in .fixtures.yml for a reproductible build." unless v.is_a?(Hash) and v.has_key?('ref') and !`git ls-remote #{v['repo']} refs/tags/#{v['ref']}`.empty?
    end
  end
end

desc 'Check tag'
task :check_tag do
  fail "You must tag the current commit for a reproductible build." unless ENV['nocheck'] or ENV['nocheck_tag'] or !`git tag --contains $(git rev-parse HEAD)`.empty?
end

desc 'Check pre-requirements'
task :build_check => [:check_branch, :check_git_status, :check_gem_version, :check_deps_version, :check_tag]

desc "Clone the repository"
task :reprepro do
  if File.file?('packages/apt/conf/distributions') and File.file?('packages/apt/conf/updates')
    sh "reprepro -b packages/apt update"
    sh "reprepro -b packages/apt export"
  end
end

desc "Build the tarball"
task :build_tarball => [:build_check, :reprepro, :spec_prep, :spec_standalone] do
  profile = File.basename(Dir.pwd)[/^puppet-(.*)$/, 1]
  tags = `git tag --contains $(git rev-parse HEAD)`.split("\n")
  version = tags[0] unless tags.length > 1
  tarball = "../#{profile}-installer-#{version}.tar.gz"
  base_path = "#{profile}-installer"
  apt_dir = 'packages/apt'

  readme   = 'README.md' if File.file?('README.md')
  packages = 'packages' if File.exist?('packages')

  sh "tar cvzfh #{tarball} #{readme} #{packages} --exclude-from .gitignore --exclude .git --exclude #{apt_dir}/conf --exclude #{apt_dir}/lists --exclude #{apt_dir}/db -C spec/fixtures modules/ --exclude modules/#{profile}/spec/fixtures/modules --exclude modules/#{profile}/packages --transform 's,^,#{base_path}/,'"

  puts "Tarball of module #{profile} built in #{tarball}."
end

desc "Build standalone installer archive"
task :build_standalone_installer => [:build_tarball, :spec_clean]

desc "Display the list of available rake tasks"
task :help do
  system("rake -T")
end

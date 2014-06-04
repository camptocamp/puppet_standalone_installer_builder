require 'rake'
require 'rspec/core/rake_task'

task :default => [:help]

desc "Clone the repository"
task :reprepro do
  sh "reprepro -b packages/apt update"
  sh "reprepro -b packages/apt export"
end

desc "Build the tarball"
task :build_tarball => [:reprepro, :spec_prep, :spec_standalone] do
  profile = File.basename(Dir.pwd)[/^puppet-(.*)$/, 1]
  tarball = "../#{profile}.tar.gz"
  apt_dir = 'packages/apt'

  sh "tar cvzfh #{tarball} README.md packages --exclude-from .gitignore --exclude .git --exclude #{apt_dir}/conf --exclude #{apt_dir}/lists --exclude #{apt_dir}/db -C spec/fixtures modules/ --exclude modules/#{profile}/spec/fixtures/modules --exclude modules/#{profile}/packages"

  puts "Tarball of module #{profile} built in #{tarball}."
end

desc "Build standalone installer archive"
task :build_standalone_installer => [:build_tarball, :spec_clean]

desc "Display the list of available rake tasks"
task :help do
  system("rake -T")
end

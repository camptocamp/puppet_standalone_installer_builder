Puppet standalone installer builder
===================================

Overview
--------

Helps you to build standalone installers for puppet.

Debian requirements
-----

```
sudo apt-get install yum-utils createrepo
```

Usage
-----

Just add this in your module Gemfile:

```
gem 'puppet_standalone_installer_builder', :github => 'camptocamp/puppet_standalone_installer_builder', :branch => 'master', :require => false
```

And this in your Rakefile

```
require 'puppet_standalone_installer_builder/rake_tasks'
```

Then run

```
bundle update
bundle exec rake build_standalone_installer
```

This will produce a tarball a the module and all dependencies.

To disable all checkes (for debugging purpose for example), you can launch:

```
bundle exec rake build_standalone_installer nocheck=true
```

Workflow for reproductible build
--------------------------------

* Branch your module for a specific release version.
* Use the same builder gem : explicitely set gem version in Gemfile.
* Use the same puppet modules : explicitely set dependencies version in .fixtures.yml.
* Use the same packages : use reprepro snapshots features on your repository server, then point to a specific snapshot in your reprepro clone configuration files.
* Call `bundle update` and `bundle exec rake build_standalone_installer` and you should get reproductible build.

The .psib.yml file
------------------

You can set some properties in a `.psib.yml` file located in the root of your module:

####profile:
Override the name of the profile (defaults to the name of the current directory without the leading `puppet-`)

####title:
Override the title of the application (defaults to `profile`)

Example:
```
---
profile: mytestprofile
title: My Test Profile
```

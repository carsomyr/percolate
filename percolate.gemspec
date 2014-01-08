# -*- coding: utf-8 -*-
#
# Copyright 2014 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require "pathname"

$LOAD_PATH.push(Pathname.new("../lib").expand_path(__FILE__).to_s)

require "percolate/version"

Gem::Specification.new do |s|
  s.name = "percolate"
  s.version = Percolate::Version.to_s
  s.platform = Gem::Platform::RUBY
  s.licenses = ["Apache-2.0"]
  s.authors = ["Roy Liu"]
  s.email = ["carsomyr@gmail.com"]
  s.homepage = "https://github.com/carsomyr/percolate"
  s.summary = "Percolate is a library for organizing and distributing configuration settings"
  s.description = "Percolate is a library for organizing and distributing configuration settings. It contains" \
    " adapters for frameworks like Chef, with which the user can take full advantage of a declarative syntax for Chef" \
    " data bags and avoid the antipattern of representing initialization state with node attributes."
  s.add_runtime_dependency "activesupport", ">= 4.0.2"

  if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new("2.0.0")
    s.add_runtime_dependency "backports", ">= 3.4.0"
  end

  s.files = Pathname.glob("lib/**/*.rb").concat(Pathname.glob("bin/*")).map { |f| f.to_s }
  s.test_files = Pathname.glob("{features,spec,test}/*").map { |f| f.to_s }
  s.executables = Pathname.glob("bin/*").map { |f| f.basename.to_s }
  s.require_paths = ["lib"]
end

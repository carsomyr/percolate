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

gem_package "percolate"

require "percolate"

chef_node = node

percolator = Percolate.create(:chef_data_bag, self) do
  entities_data_bag self.class.percolate_value(chef_node, "entities_data_bag", "entities")
end

Chef::Recipe.send(:define_method, :percolator) do
  percolator
end

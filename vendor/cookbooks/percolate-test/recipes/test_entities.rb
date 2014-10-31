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

class << self
  include Percolate
end

node.default["testing"]["entities-all"] = Hash[data_bag("entities").map do |item_name|
  content = data_bag_item("entities", item_name).raw_data
  content.delete("id")

  [item_name, content]
end]

node.default["testing"]["entities-merged"] = percolator.entities

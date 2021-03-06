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

module Percolate
  module InstanceMethods
    def percolator
      require "percolate" \
        if !defined?(Percolate::Percolator)

      chef_node = node

      @percolator ||= Percolate.create(:chef_data_bag, self) do
        if defined?(Percolate::ENTITIES_DATA_BAG)
          data_bag_name = Percolate::ENTITIES_DATA_BAG
        elsif chef_node["percolate"]["entities_data_bag"]
          data_bag_name = chef_node["percolate"]["entities_data_bag"]
        else
          data_bag_name = "entities"
        end

        entities_data_bag data_bag_name
      end
    end
  end

  def self.included(klass)
    klass.send(:include, InstanceMethods)
  end
end

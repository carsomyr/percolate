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

require "active_support/inflector"

require "percolate/adapter/base_adapter"
require "percolate/util"

module Percolate
  module Adapter
    # An adapter for loading from Chef data bags.
    class ChefDataBagAdapter < BaseAdapter
      attr_writer :entities_data_bag

      def initialize(data_source)
        super

        @entities_data_bag = "entities"
      end

      def load_entities
        @data_source.data_bag(@entities_data_bag).reduce({}) do |current, item_name|
          content_hash = @data_source.data_bag_item(@entities_data_bag, item_name).raw_data["entities"]

          if !content_hash.nil?
            Percolate::Util.merge_attributes(current, content_hash)
          else
            {}
          end
        end
      end

      def load_facet(context, name)
        name = name.to_s

        facets = @data_source.data_bag(context).map do |item_name|
          facets_hash = @data_source.data_bag_item(context, item_name).raw_data["facets"]

          if facets_hash.include?(name)
            facet_hash = facets_hash[name]
            facet_type = facet_hash.fetch("type", name)
            facet_attrs = facet_hash.fetch("attrs", {})

            configure_facet(create_facet(facet_type), facet_attrs)
          else
            nil
          end
        end.select do |item|
          !item.nil?
        end.to_a

        return nil if facets.empty?

        facets[1...facets.size].reduce(facets[0]) do |current, other|
          current.merge(other)
        end
      end
    end
  end
end

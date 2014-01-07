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

require "percolate/adapter/base_adapter"

module Percolate
  module Adapter
    # An adapter for exposing a fixed attribute `Hash`.
    class FixtureAdapter < BaseAdapter
      def initialize(data_source)
        super
      end

      def load_entities
        @data_source["entities"]
      end

      def load_facet(context, name)
        name = name.to_s

        facets_hash = @data_source["contexts"][context]["facets"]

        if facets_hash.include?(name)
          facet_hash = facets_hash[name]
          facet_type = facet_hash.fetch("type", name)
          facet_attrs = facet_hash.fetch("attrs", {})

          configure_facet(create_facet(facet_type), facet_attrs)
        else
          nil
        end
      end
    end
  end
end

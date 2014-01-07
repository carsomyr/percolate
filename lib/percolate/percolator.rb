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

module Percolate
  # Creates a {Percolator} from the given adapter name and data source.
  #
  # @param adapter_name [Symbol] the adapter name.
  # @param data_source [Object] the data source.
  # @param block [Proc] the configuration block.
  #
  # @return [Percolator] the {Percolator}.
  def self.create(adapter_name, data_source = nil, &block)
    const_str = ActiveSupport::Inflector.camelize(adapter_name) + "Adapter"

    begin
      require "percolate/adapter/#{adapter_name}_adapter"
    rescue LoadError
      # Do nothing. Give the benefit of the doubt if the file doesn't exist.
    end if !Adapter.const_defined?(const_str)

    adapter = Adapter.const_get(const_str).new(data_source)
    percolator = Percolator.new(adapter)
    percolator.load(&block)
    percolator
  end

  # The class that percolates information from entities through facets to the user.
  class Percolator
    attr_reader :adapter, :entities

    # The constructor.
    #
    # @param adapter [Object] the adapter to a data source.
    def initialize(adapter)
      @adapter = adapter
      @facet_cache = {}
    end

    # Configures and loads the underlying adapter's entities.
    #
    # @param block [Proc] the configuration block.
    def load(&block)
      @adapter.instance_eval(&block) if !block.nil?
      @entities = @adapter.load_entities

      nil
    end

    # Finds an entity.
    #
    # @param context [String] the lookup context.
    # @param facet_name [Symbol] the facet name.
    # @param args [Array] the argument splat passed to the facet.
    #
    # @return [Object] the retrieved entity.
    def find(context, facet_name, *args)
      cache_key = [context, facet_name]

      if @facet_cache.include?(cache_key)
        facet = @facet_cache[cache_key]
      else
        begin
          require "percolate/facet/#{facet_name}_facet"
        rescue LoadError
          # Do nothing. Give the benefit of the doubt if the file doesn't exist.
        end

        facet = @adapter.load_facet(context, facet_name)
        @facet_cache[cache_key] = facet
      end

      @entities[facet.find(*args)]
    end
  end

  # The namespace for adapters.
  module Adapter
  end

  # The namespace for facets.
  module Facet
  end
end

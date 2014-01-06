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
  # Creates a {Percolator} from the given adapter name.
  #
  # @param adapter_name [Symbol] the adapter name.
  # @param block [Proc] the configuration block.
  #
  # @return [Percolator] the {Percolator}.
  def self.create(adapter_name, &block)
    const_str = ActiveSupport::Inflector.camelize(adapter_name) + "Adapter"

    begin
      require "percolate/adapter/#{adapter_name}_adapter"
    rescue LoadError
      # Do nothing. Give the benefit of the doubt if the file doesn't exist.
    end if !Adapter.const_defined?(const_str)

    percolator = Percolator.new(Adapter.const_get(const_str).new)
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
    end

    # Configures and loads the underlying adapter's entities.
    #
    # @param block [Proc] the configuration block.
    def load(&block)
      @adapter.instance_eval(&block) if !block.nil?
      @entities = @adapter.load_entities

      nil
    end
  end

  # The namespace for adapters.
  module Adapter
  end
end

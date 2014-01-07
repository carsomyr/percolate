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
  module Adapter
    # A base class to build off of.
    class BaseAdapter
      # The constructor.
      #
      # @param data_source [Object] the data source.
      def initialize(data_source = nil)
        @data_source = data_source
      end

      # Loads entities in an adapter-specific way.
      #
      # @return [Hash] the loaded entities.
      def load_entities
        {}
      end

      # Loads a facet.
      #
      # @param context [String] the lookup context.
      # @param facet_name [Symbol] the facet name.
      #
      # @return [Object] the loaded facet.
      def load_facet(context, facet_name)
        create_facet(facet_name)
      end

      # Creates a facet from the given name.
      #
      # @param facet_name [Symbol] the facet name.
      #
      # @return [Object] the facet.
      def create_facet(facet_name)
        const_str = ActiveSupport::Inflector.camelize(facet_name) + "Facet"

        begin
          require "percolate/facet/#{facet_name}_facet"
        rescue LoadError
          # Do nothing. Give the benefit of the doubt if the file doesn't exist.
        end if !Facet.const_defined?(const_str)

        Facet.const_get(const_str).new
      end

      # Configures a facet according to the given attribute hash.
      #
      # @param facet [Object] the facet.
      # @param attr_hash [Hash] the attribute hash.
      #
      # @return [Object] the facet.
      def configure_facet(facet, attr_hash)
        attr_hash.each_pair do |attr, value|
          facet.send((attr + "=").to_sym, value)
        end

        facet
      end

      # If the given method isn't found, check for a setter of the same name.
      def method_missing(sym, *args, &block)
        if sym[-1] != "="
          sym_set = (sym.to_s + "=").to_sym
          return send(sym_set, *args, &block) if respond_to?(sym_set)
        end

        super
      end
    end
  end
end

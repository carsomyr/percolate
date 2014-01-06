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

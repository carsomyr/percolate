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
  module Facet
    # A base class to build off of.
    class BaseFacet
      # Finds entity information from the given input.
      #
      # @param args [Array] the argument splat.
      #
      # @return [String] the entity name.
      def find(*args)
        nil
      end

      # Merges the given facet with this one.
      #
      # @param other [BaseFacet] the other facet.
      #
      # @return [BaseFacet] this facet.
      def merge(other)
        BaseFacet.new
      end
    end
  end
end

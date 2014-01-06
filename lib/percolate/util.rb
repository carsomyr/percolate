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
  # Contains utility methods.
  module Util
    # Merges the given attributes, which can take the form of nested `Hash`es, `Array`s, and `String`s. If there is a
    # conflict, the right hand side wins.
    def self.merge_attributes(lhs, rhs)
      if lhs.is_a?(Hash) && rhs.is_a?(Hash)
        res = {}

        lhs.each_pair do |key, value|
          if rhs.include?(key)
            res[key] = merge_attributes(lhs[key], rhs[key])
          else
            res[key] = value
          end
        end

        rhs.each_pair do |key, value|
          res[key] = value if !res.include?(key)
        end
      elsif lhs.is_a?(Array) && rhs.is_a?(Array)
        res = lhs + rhs
      else
        res = rhs
      end

      res
    end
  end
end

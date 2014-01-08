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

require "set"

if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new("2.0.0")
  require "backports/2.0.0/array"
end

require "percolate/facet/base_facet"

module Percolate
  module Facet
    # A facet for looking up entities based on collections of tags.
    class TagFacet < BaseFacet
      attr_reader :poset_root

      def initialize(poset_root = nil)
        @poset_root = poset_root
      end

      # Sets the tag lookup rules.
      #
      # @param rules_hash [Hash] the lookup rules.
      def rules=(rules_hash)
        @poset_root = TagPoset.new

        rules_hash.each do |rule_hash|
          @poset_root.insert(rule_hash["tags"], rule_hash["value"])
        end

        rules_hash
      end

      def find(tags)
        @poset_root.matches(tags).sort
      end

      def merge(other)
        raise ArgumentError, "Please provide another #{self.class}" if !other.is_a?(TagFacet)

        TagFacet.new(@poset_root.merge(other.poset_root))
      end

      # A data structure representing the partial order induced on collections of tags.
      class TagPoset
        attr_reader :tags, :value, :supersets

        # The constructor.
        #
        # @param tags [Array] the tags.
        # @param value [Object] the associated value.
        # @param supersets [Array] the {TagPoset}s that contain tag supersets.
        def initialize(tags = [], value = nil, supersets = [])
          @tags = tags
          @value = value
          @supersets = supersets
        end

        # Inserts the given collection of tags and its associated value into the partial order.
        #
        # @param tags [Array] the tags.
        # @param value [Object] the associated value.
        # @param visited [Set] the visited {TagPoset}s so far, memoized by their tags.
        def insert(tags, value, visited = Set.new)
          tags = tags.sort

          # We got an exact match. Override the value and return.
          if @tags == tags
            @value = value

            return value
          end

          n_supersets = 0
          subset_indices = []

          @supersets.each_with_index do |superset, i|
            if superset.tags - tags == []
              superset.insert(tags, value, visited) if !visited.add?(superset.tags).nil?
              n_supersets = n_supersets + 1
            elsif tags - superset.tags == []
              subset_indices.push(i)
            end
          end

          # We visited a superset; there's no more work to be done in this frame.
          if n_supersets > 0
            return value
          end

          if !subset_indices.empty?
            # The tags are a subset of at least one superset; insert them in between this poset and the superset(s).
            tp = TagPoset.new(tags, value, subset_indices.map { |i| @supersets[i] })

            subset_indices.each { |i| @supersets[i] = nil }
            @supersets = @supersets.select { |item| !item.nil? }.to_a

          else
            # The tags are not a subset of any superset; insert them separately.
            tp = TagPoset.new(tags, value, transitives(tags))
          end

          # Insert the new poset with binary search for stability.
          insertion_index = (0...@supersets.size).bsearch { |i| (@supersets[i].tags <=> tags) >= 0 } || @supersets.size
          @supersets.insert(insertion_index, tp)

          value
        end

        # Finds transitive supersets that contain the given collection of tags.
        #
        # @param remainder [Array] the remaining tags to look for.
        # @param visited [Set] the visited {TagPoset}s so far, memoized by their tags.
        #
        # @return [Array] the transitive supersets.
        def transitives(remainder, visited = Set.new)
          transitives = []

          @supersets.each do |superset|
            r_remainder = remainder - superset.tags

            if r_remainder != []
              r_transitives = superset.transitives(r_remainder, visited)

              r_transitives = r_transitives.select do |r_superset|
                transitives.select do |superset|
                  superset.tags - r_superset.tags == []
                end.empty?
              end.to_a

              transitives = transitives.select do |superset|
                r_transitives.select do |r_superset|
                  r_superset.tags - superset.tags == []
                end.empty?
              end.to_a

              transitives.concat(r_transitives)
            else
              transitives.push(superset)
            end if !visited.add?(superset.tags).nil?
          end

          transitives
        end

        # Calculates the best matches for the given collection of tags.
        #
        # @param tags [Array] the tags.
        # @param visited [Set] the visited {TagPoset}s so far, memoized by their tags.
        #
        # @return [Array] the values associated with best matches.
        def matches(tags, visited = Set.new)
          tags = tags.sort

          matches = []
          n_supersets = 0

          @supersets.each do |superset|
            if superset.tags - tags == []
              matches.concat(superset.matches(tags, visited)) if !visited.add?(superset.tags).nil?
              n_supersets = n_supersets + 1
            end
          end

          # We didn't visit a superset; push on the associated value as a best match.
          if n_supersets == 0 && !@value.nil?
            matches.push(@value)
          end

          matches
        end

        # Merges the given {TagPoset} with this one.
        #
        # @param other [TagPoset] the other {TagPoset}.
        #
        # @return [TagPoset] the merged result.
        def merge(other)
          TagPoset.new.merge!(self).merge!(other)
        end

        # Mutatively merges the given {TagPoset} with this one.
        #
        # @param other [TagPoset] the other {TagPoset}.
        #
        # @return [TagPoset] `self`.
        def merge!(other, visited = Set.new)
          insert(other.tags, other.value)

          other.supersets.each do |superset|
            merge!(superset, visited) if !visited.add?(superset.tags).nil?
          end

          self
        end
      end
    end
  end
end

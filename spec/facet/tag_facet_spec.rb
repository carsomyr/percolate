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

require "percolate/facet/base_facet"
require "percolate/facet/tag_facet"

require "spec_helper"

describe Percolate::Facet::TagFacet do
  before(:all) do
    @facet = Percolate::Facet::TagFacet.new.instance_eval do
      self.rules = [
          {"tags" => [1, 2, 3, 4],
           "value" => "1 2 3 4"},
          {"tags" => [1],
           "value" => "1"},
          {"tags" => [2],
           "value" => "2"},
          {"tags" => [2, 3],
           "value" => "2 3"},
          {"tags" => [3, 4],
           "value" => "3 4"}
      ]

      self
    end
  end

  it "finds entity names by tags" do
    expect(@facet.find([1])).to eq(["1"])
    expect(@facet.find([1, 2])).to eq(["1", "2"])
    expect(@facet.find([2, 3, 4])).to eq(["2 3", "3 4"])
    expect(@facet.find([5])).to eq([])
  end

  it "merges with other facets" do
    other = Percolate::Facet::TagFacet.new.instance_eval do
      self.rules = [
          {"tags" => [2, 3],
           "value" => "[2 3]"},
          {"tags" => [3, 4],
           "value" => "[3 4]"},
          {"tags" => [4, 5],
           "value" => "4 5"},
      ]

      self
    end

    merged = @facet.merge(other)

    expect(merged.find([2, 3, 4])).to eq(["[2 3]", "[3 4]"])
    expect(merged.find([3, 4, 5])).to eq(["4 5", "[3 4]"])
    expect { @facet.merge(Percolate::Facet::BaseFacet) }.to raise_error(ArgumentError)
  end
end

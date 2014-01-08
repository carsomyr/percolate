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
require "percolate/facet/fixture_facet"

require "spec_helper"

describe Percolate::Facet::FixtureFacet do
  before(:all) do
    @facet = Percolate::Facet::FixtureFacet.new.instance_eval do
      self.fixtures = {
          "one" => "un",
          "two" => "deux",
          "three" => "trois"
      }

      self
    end
  end

  it "finds entity names" do
    expect(@facet.find("one")).to eq("un")
    expect(@facet.find("two")).to eq("deux")
    expect(@facet.find("three")).to eq("trois")
    expect(@facet.find("invalid")).to eq(nil)
  end

  it "merges with other facets" do
    other = Percolate::Facet::FixtureFacet.new.instance_eval do
      self.fixtures = {
          "one" => "uno",
          "four" => "quatre"
      }

      self
    end

    merged = @facet.merge(other)

    expect(merged.find("one")).to eq("uno")
    expect(merged.find("four")).to eq("quatre")
    expect { @facet.merge(Percolate::Facet::BaseFacet) }.to raise_error(ArgumentError)
  end
end

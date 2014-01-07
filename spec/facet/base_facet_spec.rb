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

require "spec_helper"

describe Percolate::Facet::BaseFacet do
  before(:all) do
    fixture_hash = {
        "entities" => {
            "some_entity" => "some_value"
        },
        "contexts" => {
            "some_context" => {
                "facets" => {
                    "some_facet" => {
                        "type" => "base",
                        "attrs" => {
                            "some_attr1" => "some_attr_value1",
                            "some_attr2" => "some_attr_value2"
                        }
                    }
                }
            }
        }
    }

    @percolator = Percolate.create(:fixture, fixture_hash)
  end

  it "finds entity names" do
    facet = double("facet")
    expect(facet).to receive(:some_attr1=).with("some_attr_value1")
    expect(facet).to receive(:some_attr2=).with("some_attr_value2")
    expect(facet).to receive(:find) { "some_entity" }

    allow(Percolate::Facet::BaseFacet).to receive(:new) { facet }

    expect(@percolator.find("some_context", :some_facet)).to eq("some_value")
  end
end

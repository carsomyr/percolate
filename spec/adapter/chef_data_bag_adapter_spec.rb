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

require "percolate/adapter/chef_data_bag_adapter"

require "spec_helper"

describe Percolate::Adapter::ChefDataBagAdapter do
  context "percolate-test::test_entities" do
    before(:all) do
      @entities_data_bag = {
          "item1" => {
              "entities" => {
                  "org1" => {
                      "one" => {
                          "fish" => true
                      },
                      "two" => {
                          "fish" => true
                      },
                      "red" => ["fish"],
                      "blue" => ["fish"]
                  },
                  "org2" => {
                      "some_key" => "some_value"
                  }
              }
          },
          "item2" => {
              "entities" => {
                  "org1" => {
                      "one" => {
                          "un" => true
                      },
                      "two" => "deux",
                      "three" => ["trois"],
                      "four" => "quatre"
                  }
              }
          }
      }

      ChefSpec::Server.create_data_bag("entities", @entities_data_bag)

      @runner = ChefSpec::Runner.new.converge(self.class.description)
    end

    it "reconstructs the entities data bag" do
      expect(@runner.node["testing"]["entities-all"]).to eq(@entities_data_bag)
    end

    it "merges entity attributes found in separate data bag items" do
      entities_merged = {
          "org1" => {
              "one" => {
                  "fish" => true,
                  "un" => true
              },
              "two" => "deux",
              "red" => ["fish"],
              "blue" => ["fish"],
              "three" => ["trois"],
              "four" => "quatre"
          },
          "org2" => {
              "some_key" => "some_value"
          }
      }

      expect(@runner.node["testing"]["entities-merged"]).to eq(entities_merged)
    end
  end

  context "percolate-test::test_facets" do
    it "merges facets found in separate data bag items" do
      entities_data_bag = {
          "item1" => {
              "entities" => {
                  "some_entity" => "some_value"
              }
          }
      }

      facets_data_bag = {
          "item1" => {
              "facets" => {
                  "some_facet" => {
                      "type" => "base",
                      "attrs" => {
                          "some_attr1" => "some_attr_value1"
                      }
                  }
              }
          },
          "item2" => {
              "facets" => {
                  "some_facet" => {
                      "type" => "base",
                      "attrs" => {
                          "some_attr2" => "some_attr_value2"
                      }
                  }
              }
          }
      }

      ChefSpec::Server.create_data_bag("entities", entities_data_bag)
      ChefSpec::Server.create_data_bag("some_context", facets_data_bag)

      facet1 = double("facet1")
      facet2 = double("facet2")
      facet3 = double("facet3")
      expect(facet1).to receive(:some_attr1=).with("some_attr_value1")
      expect(facet2).to receive(:some_attr2=).with("some_attr_value2")
      expect(facet1).to receive(:merge) { facet3 }.with(facet2)
      expect(facet3).to receive(:find) { "some_entity" }

      allow(Percolate::Facet::BaseFacet).to receive(:new).and_return(facet1, facet2)

      runner = ChefSpec::Runner.new.converge(self.class.description)
      expect(runner.node["testing"]["facets-merged"]).to eq("some_value")
    end
  end
end

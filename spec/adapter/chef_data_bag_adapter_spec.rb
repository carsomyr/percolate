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

      @runner = ChefSpec::ServerRunner.new(platform: "mac_os_x") do |_, server|
        server.create_data_bag("entities", @entities_data_bag)
      end.converge(self.class.description)
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
end

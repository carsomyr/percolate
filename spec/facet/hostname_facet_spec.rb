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
require "percolate/facet/hostname_facet"

require "spec_helper"

describe Percolate::Facet::HostnameFacet do
  before(:all) do
    @facet = Percolate::Facet::HostnameFacet.new.instance_eval do
      self.hostnames = {
          "www.exactmatch.com" => "exact_match"
      }
      self.domains = {
          "domainmatch.com" => "domain_match"
      }
      self.organizations = {
          "organizationmatch" => "organization_match"
      }

      self
    end
  end

  it "finds entity names by hostname" do
    expect(@facet.find("www.exactmatch.com")).to eq("exact_match")
    expect(@facet.find("www.domainmatch.com")).to eq("domain_match")
    expect(@facet.find("www.organizationmatch.com")).to eq("organization_match")
    expect(@facet.find("www.fallsthrough.com")).to eq("fallsthrough")
  end

  it "merges with other facets" do
    other = Percolate::Facet::HostnameFacet.new.instance_eval do
      self.hostnames = {
          "www.exactmatch.com" => "exact_match_other"
      }
      self.domains = {
          "domainmatchother.com" => "domain_match_other"
      }

      self
    end

    merged = @facet.merge(other)

    expect(merged.find("www.exactmatch.com")).to eq("exact_match_other")
    expect(merged.find("www.domainmatchother.com")).to eq("domain_match_other")
    expect { @facet.merge(Percolate::Facet::BaseFacet) }.to raise_error(ArgumentError)
  end
end

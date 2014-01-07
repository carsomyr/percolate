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

module Percolate
  module Facet
    # A facet for looking up entities based on hostname.
    class HostnameFacet < BaseFacet
      attr_accessor :hostnames, :domains, :organizations

      def initialize
        @hostnames = {}
        @domains = {}
        @organizations = {}
      end

      def find(hostname)
        return @hostnames[hostname] if @hostnames.include?(hostname)

        comps = hostname.split(".", -1)
        domain = comps[1...3].join(".")

        return @domains[domain] if @domains.include?(domain)

        organization = comps[1]

        @organizations.fetch(organization, organization)
      end

      def merge(other)
        raise ArgumentError, "Please provide another #{self.class}" if !other.is_a?(HostnameFacet)

        merged = HostnameFacet.new
        merged.hostnames = @hostnames.merge(other.hostnames)
        merged.domains = @domains.merge(other.domains)
        merged.organizations = @organizations.merge(other.organizations)

        merged
      end
    end
  end
end

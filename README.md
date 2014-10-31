# Percolate: A Library for Organizing and Distributing Configuration Settings

Percolate is a library for declaratively managing configuration settings and
propagating them to endpoints in a context-dependent manner. It contains
adapters for data sources like Chef data bags, with which the user can provision
machines appropriately while avoiding the antipattern of storing initialization
information in node attributes.

There are three core concepts to Percolate: entities, contexts, and facets.
**Entities** are DRY sources of information retrieved by the library. For
example, the two entities `mine` and `theirs` below contain various
configuration settings in YAML.

    ---
    entities:
      mine:
        aws_access_key: 00000000000000000000
        aws_secret_key: 0000000000000000000000000000000000000000
        aws_route53_zone_id: 00000000000000
      theirs:
        aws_route53_zone_id: 11111111111111

**Contexts** represent the type of information to retrieve. Specifying the
`aws-keys` context during a lookup may yield different results from that of the
`aws-route53` context. Consequently, contexts may contain multiple **facets**,
which are well-defined data mapping rules. For example, the `aws-keys` context
may contain a `hostname` facet that says "when the organization part of the
hostname (i.e., `domain` of `www.domain.com`) matches `theirs`, I actually
intend to use the `mine` entity's AWS keys".

    ---
    facets:
      hostname:
        attrs:
          organizations:
            theirs: mine

A **Percolator** is what binds entities, contexts, and facets together. Using
the above snippets, invoking

    percolator.find("aws-keys", :hostname, "www.theirs.org")

yields the `mine` entity, a plausible scenario if you belong to `mine` and are
managing machines on behalf of `theirs`.

While we have designed Percolate to support different data sources through the
adapter abstraction, currently only the `ChefDataBagAdapter` is supported. The
sections below discuss general installation, followed by instructions for Chef
integration.

### Installation

1.  Get the `percolate` gem.

        $ gem install percolate

    Use the library in some Ruby code.

        require "percolate"

2.  To hack on Percolate: Clone the Git repository, do the Bundler dance, and
    run the unit tests.

        $ git clone -- git://github.com/carsomyr/percolate.git
        $ cd -- percolate
        $ bundle install
        $ bundle exec rake

### Chef Integration

The `percolate` cookbook contains a single, default recipe. You can use it by
adding the following line to your Chef cookbook's `metadata.rb`.

    depends "percolate"

Any recipe that uses the Chef data bag-based `Percolator` should have the
following line.

    class << self
      include Percolate
    end

This will ensure that a `Percolator` instance is initialized and available to
all Chef recipes via the `#percolator` instance method.

**Entities** should be declared like so for a data bag named `entities` with
items `data_bag_item1` and `data_bag_item2` in YAML. (Pretend that it's JSON for
Chef purposes.)

    ---
    id: data_bag_item1
    entities:
      mine:
        aws_access_key: 00000000000000000000
        aws_secret_key: 0000000000000000000000000000000000000000
        aws_route53_zone_id: 00000000000000
      mine-testing:
        aws_access_key: 11111111111111111111
        aws_secret_key: 1111111111111111111111111111111111111111

    ---
    id: data_bag_item2
    entities:
      theirs:
        aws_route53_zone_id: 11111111111111

Note that the `ChefDataBagAdapter` understands how to deep merge entity
information declared over multiple data bag items, hence enabling a form of
multitenancy whereby different users can contribute without conflict. For
example, one could keep `mine` and `theirs` entity information in separate files
and upload them independently with `knife`.

    $ knife data bag create -- entities
    $ knife data bag from file -- entities /path/to/data_bag_item1.json
    $ knife data bag from file -- entities /path/to/data_bag_item2.json

By default, the `percolate` Chef recipe will load entities from the `entities`
data bag. You can specify an alternate data bag by setting the appropriate node
attribute.

    node["percolate"]["entities_data_bag_name"] = "other_name"

Percolate **contexts** are data bags in and of themselves. A context (data bag)
`aws-keys` may contain **facet** declarations like so.

    ---
    id: data_bag_item1
    facets:
      hostname_remap:
        type: hostname
        attrs:
          hostnames:
            testing.mine.org: mine-testing
          organizations:
            theirs: mine

Three conventions are used in the above example.

1.  A key in `facets` is the class of the facet referred to during lookups.
2.  The `type` key of the facet declaration specifies the facet class and
    defaults to the name of the facet. You can provide it if you want to
    customize the name, or if you need two facets of the same class.
3.  The `attrs` key of the facet declaration sets facet attributes that will
    affect how it maps data.

As is the case for entities, the `ChefDataBagAdapter` also understands how to
merge facets of like names declared over multiple data bag items, although
facets are responsible for handling merges with instances of their class.

To put it all together, here is a Chef recipe fragment that synthesizes the
above examples.

    # Create a Percolator instance and expose it via the `#percolator` getter.
    class << self
      include Percolate
    end

    # Assume that the Chef node name is the hostname.
    hostname = node.name

    # Retrieve the entity information.
    key_info = percolator.find("aws-keys", :hostname_remap, hostname)
    access_key = key_info["aws_access_key"]
    secret_key = key_info["aws_secret_key"]

    # The key info differs based on the hostname.
    #
    # {www.mine.org, www.theirs.org}:
    #   access_key: 00000000000000000000
    #   secret_key: 0000000000000000000000000000000000000000
    # testing.mine.org:
    #   access_key: 11111111111111111111
    #   secret_key: 1111111111111111111111111111111111111111

Please see the sections below for a list of the facet classes currently
available, along with usage examples.

### Facet Classes

#### `hostname`

The `hostname` facet maps parts of hostnames to entity names.

*   **Attributes**

    **hostnames** - A `Hash` of FQDNs to entity names.

    **domains** - A `Hash` of domains (i.e., `domain.com` of `www.domain.com`)
    to entity names.

    **organizations** - A `Hash` of organizations (i.e., `domain` of
    `www.domain.com`) to entity names.

*   **Output**

    The matched entity name in decreasing order of specificity (hostnames,
    domains, organizations). If no match was found, defaults to the organization
    part of the hostname.

*   **Example**

        facet = Percolate::Facet::HostnameFacet.new
        facet.hostnames = {
            "testing.mine.org" => "mine-testing"
        }
        facet.organizations = {
            "theirs" => "mine"
        }

        expect(facet.find("testing.mine.org")).to eq("mine-testing")
        expect(facet.find("www.theirs.org")).to eq("mine")
        expect(facet.find("dev.mine.com")).to eq("mine")
        expect(facet.find("www.some-org.com")).to eq("some-org")

#### `fixture`

The `fixture` facet maps objects (usually `String`s) to entity names.

*   **Attributes**

    **fixtures** - A `Hash` of objects to entity names.

*   **Output**

    The matched entity name, or `nil` if no match was found.

*   **Example**

        facet = Percolate::Facet::FixtureFacet.new
        facet.fixtures = {
            "a" => "aa",
            "b" => "bb"
        }

        expect(facet.find("a")).to eq("aa")
        expect(facet.find("b")).to eq("bb")
        expect(facet.find("c")).to eq(nil)

#### `tag`

The `tag` facet maps collections of tags to entity names.

*   **Attributes**

    **rules** - An array of `Hashes` with entries (`tags`, an array of tags)
    and (`value`, the entity name).

*   **Output**

    An array of "most specific" matched entity names. In other words, if the
    input tags are `["a", "b", "c"]` and there are rules for `["a"]` and
    `["a", "b"]`, the latter rule will be chosen.

*   **Example**

        facet = Percolate::Facet::TagFacet.new
        facet.rules = [
            {"tags" => ["fast_cpu"],
             "value" => "1"},
            {"tags" => ["high memory"],
             "value" => "2"},
            {"tags" => ["fast_cpu", "high_memory"],
             "value" => "3"},
            {"tags" => ["bg_jobs"],
             "value" => "4"}
        ]

        expect(facet.find(["fast_cpu",
                           "bg_jobs"])).to eq(["1", "4"])
        expect(facet.find(["fast_cpu",
                           "high_memory",
                           "bg_jobs"])).to eq(["3", "4"])

### Custom Adapters and Facets

Writing your own adapters and facets is easy. When searching for a facet given
by the symbol `facet_name`, the library will first camelize it, append
`"Facet"`, and look for it in the `Percolate::Facet` namespace. For example,

    percolator.find("some_context", :my_app, *args)

will try to instantiate the `Percolate::Facet::MyAppFacet` class. If your facet
accepts an attribute `attribute_name`, then it must have a setter named
`attribute_name=`. Note that the same rules apply to adapters, with mentions of
`Facet` replaced with `Adapter`.

### Version History

**0.9.1** (Jan 13, 2014)

* Fix the `percolate` cookbook.

**0.9.0** (Jan 12, 2014)

* Release the `percolate` gem and Chef cookbook.

### License

    Copyright 2014 Roy Liu

    Licensed under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License. You may obtain a copy
    of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
    License for the specific language governing permissions and limitations
    under the License.

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

require "percolate/adapter/base_adapter"

require "spec_helper"

describe Percolate::Adapter::BaseAdapter do
  it "invokes setter methods called without \"=\"" do
    adapter = Percolate::Adapter::BaseAdapter.new
    expect(adapter).to receive(:some_method=).with("some_value")

    adapter.instance_eval { some_method "some_value" }
  end
end

# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "rails_helper"

RSpec.describe UpgradeMembership do
  subject(:command) { UpgradeMembership.new(membership, level).call }

  context "when upgrade unavailable" do
    let(:level) { :young_adult }
    let(:membership) { create(:membership, level: :adult) }

    it { is_expected.to be_falsey }
  end

  context "when upgrade is available" do
    let(:level) { :adult }
    let(:membership) { create(:membership, level: :young_adult) }

    it { is_expected.to be_truthy }
  end
end

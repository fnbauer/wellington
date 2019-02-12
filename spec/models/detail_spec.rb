# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

RSpec.describe Detail, type: :model do
  TestDetail = Struct.new(:detail, :expected_output)

  subject(:model) { create(:detail, :with_claim) }
  it { is_expected.to be_valid }

  it "is valid to miss out some fields when it's for import" do
    model = build(:detail, :with_claim, country: nil, address_line_1: nil)
    expect(model).to_not be_valid
    expect(model.as_import).to be_valid
  end

  describe "#to_s" do
    let(:tests) do
      [
        TestDetail.new(
          Detail.new(first_name: "Spongebob", preferred_first_name: "Dr", preferred_last_name: "Who"),
          "Dr Who",
        ),
        TestDetail.new(
          Detail.new(first_name: "Spongebob", preferred_last_name: "Who?"),
          "Who?",
        ),
        TestDetail.new(
          Detail.new(first_name: "Spongebob"),
          "Spongebob",
        ),
      ]
    end

    it "uses firstname lastname if present, otherwise falls back to legal name" do
      tests.each do |test|
        expect(test.detail.to_s).to eq(test.expected_output)
      end
    end
  end
end

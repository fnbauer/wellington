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

RSpec.describe ImportPresupporters do
  let(:data) { "" }
  let(:read_stream) { StringIO.new(data) }
  let(:standard_headings) { ImportPresupportersRow::HEADINGS.join(",") }
  let(:my_description) { "test stream" }
  let(:my_fallback_email) { Faker::Internet.email }

  subject(:command) { ImportPresupporters.new(read_stream, description: my_description, fallback_email: my_fallback_email) }

  it "imports nothing when the file is empty" do
    expect { command.call }.to_not change { Membership.count }
  end

  it "fails without the right headings" do
    expect(command.call).to be false
    expect(command.errors).to include(/headings/i)
  end

  context "when just the headings" do
    let(:data) { "#{standard_headings}\n\n\n" }

    it "fails complaining about the body" do
      expect(command.call).to be false
      expect(command.errors).to include(/empty rows/i)
    end
  end

  context "with import data" do
    let(:data) do
      CSV.generate do |csv|
        csv << ImportPresupportersRow::HEADINGS
        csv << row_1
        csv << row_2
      end
    end
    let(:email_address) { "test@matthew.nz" }
    let(:good_row_processor) { instance_double(ImportPresupportersRow, call: true) }
    let(:bad_row_processor) { instance_double(ImportPresupportersRow, call: false, error_message: "gah") }

    let(:row_1) { ["1"] * ImportPresupportersRow::HEADINGS.count }
    let(:row_2) { ["2"] * ImportPresupportersRow::HEADINGS.count }

    it "calls ProcessRow" do
      expect(ImportPresupportersRow)
        .to receive(:new)
        .and_return(good_row_processor)
      expect(ImportPresupportersRow)
        .to receive(:new)
        .and_return(good_row_processor)
      expect(command.call).to be_truthy
      expect(command.errors).to be_empty
    end

    it "raises errors with buggy rows" do
      expect(ImportPresupportersRow)
        .to receive(:new)
        .and_return(good_row_processor)
      expect(ImportPresupportersRow)
        .to receive(:new)
        .and_return(bad_row_processor)
      expect(command.call).to be_falsey
      expect(command.errors).to include(/gah/i)
    end
  end

  context "when email address is empty" do
    let(:my_fallback_email) { "" }

    it "fails with errors" do
      expect { command }.to raise_error(ArgumentError)
    end
  end

  context "when default address already in use" do
    before { create(:user, email: my_fallback_email) }

    it "executes successfully" do
      expect(command).to be_truthy
    end
  end
end

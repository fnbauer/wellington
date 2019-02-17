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

class MembershipOffer
  attr_reader :membership

  def self.options
    Membership.active.map { |m| MembershipOffer.new(m) }
  end

  def initialize(membership)
    @membership = membership
  end

  def to_s
    "#{membership} (#{formatted_price})"
  end

  # TODO Extract to i18n
  def formatted_price
    "$%.2f NZD" % (membership.price * 1.0 / 100)
  end
end
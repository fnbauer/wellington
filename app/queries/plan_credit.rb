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

# PlanCredit represents the form logic for creating 'cash' Charge records by a Support login
# It's useful for form logic, validation and provides everything you'd need to call ApplyCredit
class PlanCredit
  include ActiveModel::Model
  include ActiveModel::Validations::ClassMethods

  attr_accessor :amount # whole dollars, or pounds, or euros

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0.01 }

  # Convert amount to cents so we can store it with the Money gem
  def money
    Money.from_amount(amount.to_f)
  end
end

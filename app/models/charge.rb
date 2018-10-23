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

class Charge < ApplicationRecord
  FAILED = "failed"
  SUCCEEDED = "succeeded"

  belongs_to :user
  belongs_to :membership

  validates :comment, presence: true
  validates :status, inclusion: {in: [FAILED, SUCCEEDED]}
  validates :stripe_id, presence: true
  validates :cost, presence: true, null: false

  scope :failed, ->() { where(status: FAILED) }
  scope :succeeded, ->() { where(status: SUCCEEDED) }
end

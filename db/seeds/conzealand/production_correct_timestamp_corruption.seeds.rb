# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

imported_users = User.joins(:notes).where("notes.content LIKE ?", "Import%").distinct
purchases = Purchase.includes(:charges, :orders).joins(claims: :user)
imported_purchases = purchases.where(users: { id: imported_users })
imported_purchases.find_each.with_index(1) do |purchase, counter|
  # Find the earliest claim, charge and order for the purchase
  earliest_claim = purchase.claims.min(&:created_at)
  earliest_order = purchase.orders.min(&:created_at)
  kansa_charge = purchase.charges.find { |c| c.comment&.match(/kansa payment/i) }

  # Find the earliest timestamp between all these models
  earliest_at = [
    purchase.created_at,
    earliest_claim.created_at,
    earliest_order.created_at,
    kansa_charge&.created_at # allow for purchases without charges ($0 purchase)
  ].compact.min

  puts "#{counter}/#{imported_purchases.count}: Setting Purchase.find(#{purchase.id}) to #{earliest_at}"

  # Reset created at and active_from to be from this timestamp
  purchase.update!(created_at: earliest_at)
  earliest_claim.update!(created_at: earliest_at, active_from: earliest_at)
  earliest_order.update!(created_at: earliest_at, active_from: earliest_at)

  # Set earliest charge if it was close to the original purchase
  # $0 members are skipped, e,g. child member
  next unless kansa_charge.present?

  kansa_charge.update!(created_at: earliest_at + 1.second)
end
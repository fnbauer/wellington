# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 Chris Rose
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

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

announcement = Date.parse("2018-08-25").midday
presupport_start = announcement - 2.years

FactoryBot.create(:membership, :silver_fern , active_from: presupport_start, active_to: announcement)
FactoryBot.create(:membership, :kiwi        , active_from: presupport_start, active_to: announcement)
FactoryBot.create(:membership, :tuatara     , active_from: presupport_start, active_to: announcement)
FactoryBot.create(:membership, :pre_oppose  , active_from: presupport_start, active_to: announcement)
FactoryBot.create(:membership, :pre_support , active_from: presupport_start, active_to: announcement)

FactoryBot.create(:membership, :adult       , active_from: announcement)
FactoryBot.create(:membership, :young_adult , active_from: announcement)
FactoryBot.create(:membership, :unwaged     , active_from: announcement)
FactoryBot.create(:membership, :child       , active_from: announcement)
FactoryBot.create(:membership, :kid_in_tow  , active_from: announcement)
FactoryBot.create(:membership, :supporting  , active_from: announcement)

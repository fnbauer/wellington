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

class NominationsController < ApplicationController
  before_action :lookup_reservation!
  before_action :check_access!
  before_action :lookup_election!
  before_action :lookup_legal_name_or_redirect

  def show
    builder = MemberNominationsByCategory.new(categories: @election.categories, reservation: @reservation)
    builder.from_reservation
    @nominations_by_category = builder.nominations_by_category
    @privacy_warning = current_user.reservations.count > 1
  end

  def update
    builder = MemberNominationsByCategory.new(categories: @election.categories, reservation: @reservation)
    builder.from_params(params)
    builder.save
    @category = Category.find(params[:category_id])
    @nominations_by_category = builder.nominations_by_category

    if request.xhr?
      category_decorator = CategoryFormDecorator.new(@category, @nominations_by_category[@category])
      render json: {
        updated_heading: category_decorator.heading,
        updated_classes: category_decorator.accordion_classes,
      }
      return
    end

    # Render happens if someone hits the "submit all" button
    render "nominations/show"
  end

  private

  def lookup_election!
    @election = Election.find_by!(i18n_key: params[:id])
  end

  def check_access!
    now = DateTime.now

    if now < $nomination_opens_at
      raise ActiveRecord::RecordNotFound
    end

    if $voting_opens_at < now
      raise ActiveRecord::RecordNotFound
    end

    if !@reservation.membership.can_nominate?
      raise ActiveRecord::RecordNotFound
    end
  end

  def lookup_legal_name_or_redirect
    detail = @reservation.active_claim.detail
    if !detail.present?
      flash[:notice] = "Please enter your details to nominate for hugo"
      redirect_to @reservation
      return
    end

    @legal_name = detail.legal_name
  end

  def nomination_params
    params.require(:category).require(:nomination)
  end
end

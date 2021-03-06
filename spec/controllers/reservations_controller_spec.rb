# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

require "rails_helper"

RSpec.describe ReservationsController, type: :controller do
  render_views

  # e.g. conzealand_contact, chicago_contact
  let(:contact_model_key) { Claim.contact_strategy.to_s.underscore.to_sym }

  let!(:kidit) { create(:membership, :kidit) }
  let!(:adult) { create(:membership, :adult) }
  let!(:offer) { MembershipOffer.new(adult) }
  let!(:existing_reservation) { create(:reservation, :with_claim_from_user, membership: adult) }
  let!(:original_user) { existing_reservation.user }

  let(:another_user) { create(:user) }
  let(:support) { create(:support) }

  let(:valid_contact_params) do
    FactoryBot.build(:chicago_contact).slice(
      :first_name,
      :last_name,
      :publication_format,
      :address_line_1,
      :country,
      :email,
    )
  end

  describe "#new" do
    it "renders" do
      sign_in(original_user)
      get :new, params: { offer: offer.hash }
      expect(response).to have_http_status(:ok)
    end

    it "renders when signed out" do
      get :new, params: { offer: offer.hash }
      expect(response).to have_http_status(:ok)
    end
  end

  context "when membership is no longer available" do
    let(:price_change_at) { 1.second.ago }

    before do
      sign_in(original_user)
      adult.update!(active_to: price_change_at)
      adult.dup.save!(
        active_from: price_change_at,
        price: adult.price + Money.new(50_00),
      )
    end

    describe "#new" do
      before do
        get :new, params: { offer: offer.hash }
      end

      it "redirects back to memberships" do
        expect(response).to have_http_status(:found)
      end

      it "sets error mentioning the original offer" do
        expect(flash[:error]).to be_present
        expect(flash[:error]).to include(offer.hash)
      end
    end

    describe "#create" do
      before do
        post :create, params: {
          contact_model_key => valid_contact_params,
          :offer => offer.hash,
        }
      end

      it "redirects back to memberships" do
        expect(response).to have_http_status(:found)
      end

      it "sets error mentioning the original offer" do
        expect(flash[:error]).to be_present
        expect(flash[:error]).to include(offer.hash)
      end
    end
  end



  describe "#index" do
    it "renders" do
      sign_in(original_user)
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "renders when signed out" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "can't be found when not signed in" do
      expect(get :show, params: { id: existing_reservation.id })
        .to have_http_status(:forbidden)
    end

    it "cant find it when you're signed in as a different user" do
      sign_in(another_user)
      expect(get :show, params: { id: existing_reservation.id })
        .to have_http_status(:forbidden)
    end

    it "can find your own reservations" do
      sign_in(original_user)
      get :show, params: { id: existing_reservation.id }
      expect(response).to have_http_status(:ok)
    end

    context "when signed in as support" do
      before { sign_in(support) }

      it "can view any membership" do
        get :show, params: { id: existing_reservation.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "after transferring a membership" do
      before do
        ApplyTransfer.new(existing_reservation, from: original_user, to: another_user, audit_by: support.email).call
      end

      it "can't be found for original user" do
        sign_in(original_user)
        expect(get :show, params: { id: existing_reservation.id })
          .to have_http_status(:forbidden)
      end

      it "is found for new user" do
        sign_in(another_user)
        get :show, params: { id: existing_reservation.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#update" do
    let(:updated_address) { "yolo" }
    let(:target_contact) { existing_reservation.active_claim.contact }

    let(:valid_params) do
      {
        id: existing_reservation.reload.id,
        contact_model_key => {
          :first_name => "this",
          :last_name => "is",
          :address_line_1 => updated_address,
          :country => "valid",
          :publication_format => ChicagoContact::PAPERPUBS_NONE,
        }
      }
    end

    it "can't be found when not signed in" do
      expect(get :show, params: valid_params).to have_http_status(:forbidden)
    end

    context "when signed in as support" do
      before { sign_in(support) }

      it "updates when all values present" do
        post :update, params: valid_params
        expect(flash[:notice]).to match(/updated/i)
        expect(Claim.contact_strategy.last.address_line_1).to eq updated_address
      end
    end

    context "when signed in as user" do
      before { sign_in(original_user) }

      it "updates when all values present" do
        post :update, params: valid_params
        expect(flash[:notice]).to match(/updated/i)
        expect(Claim.contact_strategy.last.address_line_1).to eq updated_address
      end

      context "with no contact set" do
        before do
          ChicagoContact.where(claim_id: original_user.active_claims).destroy_all
        end

        it "updates when all values present" do
          post :update, params: valid_params
          expect(flash[:notice]).to match(/updated/i)
          expect(Claim.contact_strategy.last.address_line_1).to eq updated_address
        end
      end

      it "shows error when values not present" do
        post :update, params: {
          :id => existing_reservation.id,
          contact_model_key => {
            :first_name => "this",
            :last_name => "is",
            :address_line_1 => "",
            :country => "valid",
          }
        }
        expect(flash[:error]).to match(/address/i)
        expect(response).to have_http_status(:ok)
      end

      it "lets you update title" do
        contact_attributes = existing_reservation.active_claim.contact.attributes
        contact_attributes["title"] = "Positively Smashed"
        post :update, params: {
          :id => existing_reservation.id,
          contact_model_key => contact_attributes
        }
        expect(existing_reservation.reload.active_claim.contact.title).to eq "Positively Smashed"
      end
    end
  end

  describe "#create" do
    before { sign_in(original_user) }

    context "when user doesn't provide their email" do
      context "when the user requests epubs" do
        before do
          post :create, params: {
            contact_model_key => {
              :first_name => "Validscotch",
              :last_name => "Sparkle-Valid",
              :address_line_1 => "Valid Meadows",
              :country => "The Very Valid Nation of Equestria",
              :publication_format => ChicagoContact::PAPERPUBS_ELECTRONIC,
            },
            :offer => offer.hash,
          }
        end

        it "sets errors mentioning email and publications" do
          expect(flash[:error]).to be_present
          expect(flash[:error]).to include("email")
          expect(flash[:error]).to include("publications")
        end

        it "re-renders the reservaton page" do
          expect(response.body).to include("Reserve a New Membership")
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the user requests printpubs" do
        before do
          post :create, params: {
            contact_model_key => {
              :first_name => "Validanne",
              :last_name => "Validbury",
              :address_line_1 => "Valid-on-Thames",
              :country => "Valbion",
              :publication_format => ChicagoContact::PAPERPUBS_MAIL},
            :offer => offer.hash,
          }
        end

        it "does not set errors" do
          expect(flash[:error]).to_not be_present
        end

        it "redirects to the charges page" do
          expect(response.headers["Location"]).to match(/charges/)
          expect(response).to have_http_status(:found)
        end
      end
    end

    context "when user email is provided" do
      context "when adult offer selected" do
        before do
          post :create, params: {
            contact_model_key => valid_contact_params,
            :offer => offer.hash,
          }
        end

        it "redirects to the charges page" do
          expect(response.headers["Location"]).to match(/charges/)
          expect(response).to have_http_status(:found)
        end

        it "does not set an error flash" do
          expect(flash[:error]).to_not be_present
        end

      end

      context "when free offer selected" do
        before do
          post :create, params: {
            contact_model_key => {
              :first_name => "Silly",
              :last_name => "Billy",
              :address_line_1 => "valid",
              :country => "valid",
              :publication_format => ChicagoContact::PAPERPUBS_NONE,
            },
            :offer => MembershipOffer.new(kidit).hash
          }
        end

        it "does not set error flash" do
          expect(flash[:error]).to_not be_present
        end

        it "redirects to the reservation page" do
          expect(response).to have_http_status(:found)
          expect(response.headers["Location"]).to match(/reservations/)
        end
      end
    end
  end

  describe "#reserve_with_cheque" do
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }
    before { sign_in(original_user) }

    let(:params) {
      {
        contact_model_key => {
        :first_name => "Validanne",
        :last_name => "Validbury",
        :address_line_1 => "Valid-on-Thames",
        :country => "Valbion",
        :publication_format => ChicagoContact::PAPERPUBS_NONE},
      :offer => offer.hash,
      }
    }

    it "notifies about the email" do
      post :reserve_with_cheque, params: params
      expect(flash[:notice]).to be_present
    end

    it "emails the user" do
      expect(PaymentMailer).to receive_message_chain(:waiting_for_cheque, :deliver_later).and_return(true)
      post :reserve_with_cheque, params: params
    end

    it "redirects to the reservation page" do
      post :reserve_with_cheque, params: params
      expect(response).to have_http_status(:found)
      expect(response.headers["Location"]).to match(/reservations/)
    end
  end
end

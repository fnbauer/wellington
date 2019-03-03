# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
# Copyright 2019 AJ Esler
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

RSpec.describe ChargesController, type: :controller do
  include Warden::Test::Helpers
  render_views

  let(:purchase) { create(:purchase, :with_order_against_membership, :with_claim_from_user, :pay_as_you_go) }
  let(:user) { purchase.user }

  before { sign_in(user) }

  describe "#new" do
    context "when the purchase is paid for" do
      before { purchase.update!(state: Purchase::PAID) }

      it "redirects to the purchase" do
        get :new, params: { purchaseId: purchase.id }

        expect(response).to redirect_to(purchase_path(purchase.membership_number))
      end

      it "returns a flash notice" do
        get :new, params: { purchaseId: purchase.id }

        expect(flash[:notice]).to match /membership has already been paid for/
      end
    end

    context "when the purchase has not been paid for" do
      it "renders" do
        get :new, params: { purchaseId: purchase.id }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#create" do
    let(:amount) { 23000 }
    let(:amount_owed) { 10 }
    let(:stripe_token) { "stripe-token" }
    let(:params) do
      {
        stripeToken: stripe_token,
        amount: amount,
        purchaseId: purchase.id,
      }
    end
    let(:charge_double) { instance_double(Charge, amount: amount) }

    before do
      amount_owed_double = instance_double(AmountOwedForPurchase)
      expect(AmountOwedForPurchase).to receive(:new).and_return(amount_owed_double)
      expect(amount_owed_double).to receive(:amount_owed).and_return(amount_owed)

      expect(ChargeCustomer).to receive(:new).with(purchase, user, stripe_token, amount_owed, charge_amount: amount).and_return(instance_double(ChargeCustomer, call: charge_success, charge: charge_double, error_message: "error"))
    end

    context "when the charge is unsuccessful" do
      let(:charge_success) { false }

      it "sets a flash error" do
        post :create, params: params

        expect(flash[:error]).to be_present
      end

      it "redirects to the new charge form" do
        post :create, params: params

        expect(response).to redirect_to(new_charge_path(purchaseId: purchase.id))
      end
    end

    context "when the charge is successful" do
      let(:charge_success) { true }
      let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }

      it "sends an email" do
        expect(PaymentMailer).to receive(:new_member).with(user: user, purchase: purchase, charge: charge_double).and_return(mail)
        expect(mail).to receive(:deliver_later)

        post :create, params: params
      end

      context "after email has been sent" do
        before do
          allow(PaymentMailer).to receive(:new_member).and_return(mail)
        end

        it "redirects to the purchase" do
          post :create, params: params

          expect(response).to redirect_to(purchase_path(purchase))
        end

        it "sets a flash notice" do
          post :create, params: params

          expect(flash[:notice]).to be_present
        end
      end
    end
  end
end

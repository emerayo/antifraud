# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/transactions', type: :request do
  let(:device_id) { 285_475 }
  let(:merchant_id) { 29_744 }
  let(:user_id) { 97_051 }

  let(:valid_attributes) do
    {
      id: 21_320_398,
      merchant_id: merchant_id,
      user_id: user_id,
      card_number: '434505******9116',
      date: '2019-12-01T23:16:32.812632',
      amount: 374.56,
      device_id: device_id
    }
  end

  let(:invalid_attributes) do
    {
      id: 21_320_398,
      merchant_id: 0,
      user_id: user_id,
      card_number: '434505******9116',
      date: '2019-12-01T23:16:32.812632',
      amount: 374.56,
      device_id: device_id
    }
  end

  let(:json_response) { response.parsed_body }

  describe 'GET /show' do
    context 'when the Transaction exists' do
      let!(:device) { Device.create(id: device_id) }
      let!(:merchant) { Merchant.create(id: merchant_id) }
      let!(:user) { User.create(id: user_id) }
      let!(:transaction) { Transaction.create! valid_attributes }

      it 'returns the Transaction and status 200' do
        get api_v1_transaction_path(transaction)

        expect(json_response['id']).to eq transaction.id
        expect(json_response['device_id']).to eq transaction.device_id
        expect(json_response['merchant_id']).to eq transaction.merchant_id
        expect(json_response['user_id']).to eq transaction.user_id
        expect(json_response['amount']).to eq transaction.amount
        expect(response.status).to eq 200
      end
    end

    context 'when the Transaction does not exist' do
      it 'returns 404' do
        get api_v1_transaction_path(1)

        expect(json_response).to eq({ 'error' => 'not-found' })
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      let!(:device) { Device.create(id: device_id) }
      let!(:merchant) { Merchant.create(id: merchant_id) }
      let!(:user) { User.create(id: user_id) }

      it 'creates a new Transaction and redirects to the created transaction' do
        expect { post api_v1_transactions_path, params: { transaction: valid_attributes } }
          .to change(Transaction, :count).from(0).to(1)

        expect(json_response['id']).to eq valid_attributes[:id]
        expect(json_response['device_id']).to eq device_id
        expect(json_response['merchant_id']).to eq merchant_id
        expect(json_response['user_id']).to eq user_id
        expect(json_response['amount']).to eq valid_attributes[:amount]
        expect(response.status).to eq 201
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Transaction and renders a response with 422 status' do
        expect { post api_v1_transactions_path, params: { transaction: invalid_attributes } }
          .to change(Transaction, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

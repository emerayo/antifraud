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

  let(:json_response) { response.parsed_body }

  let(:http_auth) do
    user = ENV.fetch('AUTH_USER', nil)
    password = ENV.fetch('AUTH_PASS', nil)
    {
      HTTP_AUTHORIZATION:
        ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
    }
  end

  describe 'GET /show' do
    context 'when the Transaction exists' do
      let!(:device) { Device.create(id: device_id) }
      let!(:merchant) { Merchant.create(id: merchant_id) }
      let!(:user) { User.create(id: user_id) }
      let!(:transaction) { Transaction.create! valid_attributes }

      it 'returns the Transaction and status 200' do
        get api_v1_transaction_path(transaction), headers: http_auth

        expect(json_response['id']).to eq transaction.id
        expect(response.status).to eq 200
      end
    end

    context 'when the Transaction does not exist' do
      it 'returns 404' do
        get api_v1_transaction_path(1), headers: http_auth

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

      context 'with valid previous transactions or no transactions' do
        it 'creates a new Transaction and renders the transaction' do
          expect do
            post api_v1_transactions_path, params: { transaction: valid_attributes },
                                           headers: http_auth
          end.to change(Transaction, :count).from(0).to(1)

          expect(json_response['id']).to eq valid_attributes[:id]
          expect(json_response['recommendation']).to eq 'approve'
          expect(response.status).to eq 201
        end

        context 'without device on the database' do
          let!(:merchant) { Merchant.create(id: merchant_id) }
          let!(:user) { User.create(id: user_id) }

          it 'creates a new Transaction with blank device and renders the transaction' do
            expect do
              post api_v1_transactions_path, params: { transaction: valid_attributes },
                                             headers: http_auth
            end.to change(Transaction, :count).by(1)
            expect(json_response['id']).to eq valid_attributes[:id]
            expect(json_response['recommendation']).to eq 'approve'
            expect(response.status).to eq 201
          end
        end
      end

      context 'with invalid previous transactions' do
        context 'when there is at least one chargeback for user' do
          let!(:transaction_with_chargeback) do
            Transaction.create!(valid_attributes.merge(id: 21_320_333, has_cbk: true))
          end

          it 'creates a new Transaction and renders the transaction with recommendation deny' do
            expect do
              post api_v1_transactions_path, params: { transaction: valid_attributes },
                                             headers: http_auth
            end.to change(Transaction, :count).from(1).to(2)

            expect(json_response['id']).to eq valid_attributes[:id]
            expect(json_response['recommendation']).to eq 'deny'
            expect(response.status).to eq 201
          end
        end
      end
    end

    context 'with invalid parameters' do
      context 'without merchant on the database' do
        let!(:device) { Device.create(id: device_id) }
        let!(:user) { User.create(id: user_id) }

        it 'does not create a new Transaction and renders a response with 422 status' do
          expect do
            post api_v1_transactions_path, params: { transaction: valid_attributes },
                                           headers: http_auth
          end.to change(Transaction, :count).by(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to eq({ 'merchant' => ['must exist'] })
        end
      end

      context 'without user on the database' do
        let!(:device) { Device.create(id: device_id) }
        let!(:merchant) { Merchant.create(id: merchant_id) }

        it 'does not create a new Transaction and renders a response with 422 status' do
          expect do
            post api_v1_transactions_path, params: { transaction: valid_attributes },
                                           headers: http_auth
          end.to change(Transaction, :count).by(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to eq({ 'user' => ['must exist'] })
        end
      end

      context 'with invalid amount' do
        let!(:device) { Device.create(id: device_id) }
        let!(:merchant) { Merchant.create(id: merchant_id) }
        let!(:user) { User.create(id: user_id) }

        context 'with negative amount' do
          it 'does not create a new Transaction and renders a response with 422 status' do
            valid_attributes[:amount] = -1

            expect do
              post api_v1_transactions_path, params: { transaction: valid_attributes },
                                             headers: http_auth
            end.to change(Transaction, :count).by(0)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response['errors']).to eq({ 'amount' => ['must be greater than 0'] })
          end
        end

        context 'with zero amount' do
          it 'does not create a new Transaction and renders a response with 422 status' do
            valid_attributes[:amount] = 0

            expect do
              post api_v1_transactions_path, params: { transaction: valid_attributes },
                                             headers: http_auth
            end.to change(Transaction, :count).by(0)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response['errors']).to eq({ 'amount' => ['must be greater than 0'] })
          end
        end
      end
    end
  end

  describe 'PATCH /chargeback' do
    context 'when the Transaction exists' do
      let!(:device) { Device.create(id: device_id) }
      let!(:merchant) { Merchant.create(id: merchant_id) }
      let!(:user) { User.create(id: user_id) }
      let!(:transaction) { Transaction.create! valid_attributes }

      context 'when the Transaction is valid' do
        it 'updates the has_cbk field and returns the Transaction and status 200' do
          expect(transaction.has_cbk).to eq false

          patch chargeback_api_v1_transaction_path(transaction), headers: http_auth

          expect(transaction.reload.has_cbk).to eq true
          expect(json_response['id']).to eq transaction.id
          expect(json_response['has_cbk']).to eq true
          expect(response.status).to eq 200
        end
      end

      context 'when the Transaction is not valid anymore' do
        it 'returns 422' do
          transaction.amount = 0
          transaction.save(validate: false)

          patch chargeback_api_v1_transaction_path(transaction), headers: http_auth

          expect(json_response).to eq({ 'errors' => { 'amount' => ['must be greater than 0'] } })
          expect(response.status).to eq 422
        end
      end
    end

    context 'when the Transaction does not exist' do
      it 'returns 404' do
        patch chargeback_api_v1_transaction_path(1), headers: http_auth

        expect(json_response).to eq({ 'error' => 'not-found' })
        expect(response.status).to eq 404
      end
    end
  end
end

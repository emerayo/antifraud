# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecommendationService do
  let(:device_id) { 285_475 }
  let(:merchant_id) { 29_744 }
  let(:user_id) { 97_051 }

  let!(:device) { Device.create(id: device_id) }
  let!(:merchant) { Merchant.create(id: merchant_id) }
  let!(:user) { User.create(id: user_id) }

  let(:date) { DateTime.parse('2024-01-25 18:03:28.604436') }

  let(:valid_attributes) do
    {
      id: 21_320_398,
      merchant_id: merchant_id,
      user_id: user_id,
      card_number: '434505******9116',
      date: date,
      amount: 374.56,
      device_id: device_id
    }
  end

  subject { described_class.new(transaction: Transaction.new(valid_attributes)) }

  context 'with valid previous transactions' do
    context 'when there is no other transaction' do
      it 'approves the transaction' do
        recommendation = subject.recommend

        expect(recommendation).to eq 'approve'
      end
    end

    context 'when there are other transactions' do
      context 'when there are transaction in the last hour' do
        context 'when the amount is different' do
          before do
            Transaction.create!({ id: 22_320_500,
                                  merchant_id: merchant_id,
                                  user_id: user_id,
                                  card_number: '434505******9116',
                                  date: 10.minutes.ago,
                                  amount: 200.56,
                                  device_id: device_id })
          end

          it 'approves the transaction' do
            recommendation = subject.recommend

            expect(recommendation).to eq 'approve'
          end
        end

        context "when the transactions' amount is below the one hour limit amount" do
          before do
            Transaction.create!({ id: 22_320_500,
                                  merchant_id: merchant_id,
                                  user_id: user_id,
                                  card_number: '434505******9116',
                                  date: date - 40.minutes,
                                  amount: 999.99,
                                  device_id: device_id })
          end

          it 'approves the transaction' do
            recommendation = subject.recommend

            expect(recommendation).to eq 'approve'
          end
        end

        context 'when the amount is same but merchant_id is different' do
          before do
            new_merchant_id = 233
            Merchant.create(id: new_merchant_id)
            Transaction.create!({ id: 22_320_500,
                                  merchant_id: new_merchant_id,
                                  user_id: user_id,
                                  card_number: '434505******9116',
                                  date: date - 2.hours,
                                  amount: 374.56,
                                  device_id: device_id })
          end

          it 'approves the transaction' do
            recommendation = subject.recommend

            expect(recommendation).to eq 'approve'
          end
        end

        context 'when the amount and device_is are different' do
          before do
            new_device_id = 444
            Device.create(id: new_device_id)
            Transaction.create!({ id: 22_320_500,
                                  merchant_id: merchant_id,
                                  user_id: user_id,
                                  card_number: '434505******9116',
                                  date: 30.minutes.ago,
                                  amount: 43.13,
                                  device_id: new_device_id })
          end

          it 'approves the transaction' do
            recommendation = subject.recommend

            expect(recommendation).to eq 'approve'
          end
        end
      end

      context "when the transactions' amount is below the five hours limit amount" do
        before do
          Transaction.create!({ id: 22_320_500,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: 3.hours.ago,
                                amount: 4_999.99,
                                device_id: device_id })
        end

        it 'approves the transaction' do
          recommendation = subject.recommend

          expect(recommendation).to eq 'approve'
        end
      end
    end
  end

  context 'with invalid previous transactions' do
    context 'when there are transaction in the last hour' do
      context 'when there is another transaction with same value in last hour' do
        let!(:same_value_transaction) do
          Transaction.create!(valid_attributes.merge(id: 21_320_222))
        end

        it 'denies the transaction' do
          Transaction.create!(valid_attributes)

          recommendation = subject.recommend

          expect(recommendation).to eq 'deny'
        end
      end

      context "when the transactions' amount is equal as the one hour limit amount" do
        before do
          Transaction.create!({ id: 22_320_500,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: date - 40.minutes,
                                amount: 1_000,
                                device_id: device_id })
        end

        it 'denies the transaction' do
          recommendation = subject.recommend

          expect(recommendation).to eq 'deny'
        end
      end

      context 'when there are more too many transactions in different devices in last hour' do
        before do
          Transaction.create!({ id: 22_320_500,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: date - 30.minutes,
                                amount: 374.56,
                                device_id: device_id })

          Transaction.create!({ id: 22_320_300,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: date - 40.minutes,
                                amount: 21.56,
                                device_id: device_id })
        end

        it 'denies the transaction' do
          recommendation = subject.recommend

          expect(recommendation).to eq 'deny'
        end
      end

      context 'when there are more too many transactions in same device in last hour' do
        before do
          device_id_one = 444
          Device.create(id: device_id_one)
          Transaction.create!({ id: 22_320_500,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: date - 30.minutes,
                                amount: 374.56,
                                device_id: device_id_one })

          device_id_two = 555
          Device.create(id: device_id_two)
          Transaction.create!({ id: 22_320_300,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: date - 40.minutes,
                                amount: 374.56,
                                device_id: device_id_two })
        end

        it 'denies the transaction' do
          recommendation = subject.recommend

          expect(recommendation).to eq 'deny'
        end
      end
    end

    context "when there is one transaction with recommendation 'deny' for user" do
      let!(:transaction_denied) do
        Transaction.create!(valid_attributes.merge(id: 21_320_311, recommendation: 'deny'))
      end

      it 'denies the transaction' do
        recommendation = subject.recommend

        expect(recommendation).to eq 'deny'
      end
    end

    context 'when there is at least one chargeback for user' do
      let!(:transaction_with_chargeback) do
        Transaction.create!(valid_attributes.merge(id: 21_320_333, has_cbk: true))
      end

      it 'denies the transaction' do
        recommendation = subject.recommend

        expect(recommendation).to eq 'deny'
      end
    end

    context "when the transactions' amount is equal the five hours limit amount" do
      before do
        Transaction.create!({ id: 22_320_500,
                              merchant_id: merchant_id,
                              user_id: user_id,
                              card_number: '434505******9116',
                              date: date - 3.hours,
                              amount: 5_000,
                              device_id: device_id })
      end

      it 'denies the transaction' do
        recommendation = subject.recommend

        expect(recommendation).to eq 'deny'
      end
    end
  end
end

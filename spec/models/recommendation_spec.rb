# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recommendation do
  let(:device_id) { 285_475 }
  let(:merchant_id) { 29_744 }
  let(:user_id) { 97_051 }

  let!(:device) { Device.create(id: device_id) }
  let!(:merchant) { Merchant.create(id: merchant_id) }
  let!(:user) { User.create(id: user_id) }

  let(:valid_attributes) do
    {
      id: 21_320_398,
      merchant_id: merchant_id,
      user_id: user_id,
      card_number: '434505******9116',
      date: 1.hour.ago,
      amount: 374.56,
      device_id: device_id
    }
  end

  let(:transaction) { Transaction.new(valid_attributes) }
  let(:empty_transactions) { Transaction.none }
  let(:all_transactions) { Transaction.all }

  subject do
    described_class.new(transaction: transaction,
                        transactions: transactions,
                        chargeback: chargeback)
  end

  context 'with valid previous transactions' do
    let(:chargeback) { false }
    let(:transactions) { all_transactions }

    context 'when there is no other transaction' do
      let(:transactions) { empty_transactions }

      it 'returns valid' do
        expect(subject.valid?).to eq true
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

          it 'returns valid' do
            expect(subject.valid?).to eq true
          end
        end

        context "when the transactions' amount is below the one hour limit amount" do
          before do
            Transaction.create!({ id: 22_320_500,
                                  merchant_id: merchant_id,
                                  user_id: user_id,
                                  card_number: '434505******9116',
                                  date: 40.minutes.ago,
                                  amount: 999.99,
                                  device_id: device_id })
          end

          it 'returns valid' do
            expect(subject.valid?).to eq true
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
                                  date: 2.hours.ago,
                                  amount: 374.56,
                                  device_id: device_id })
          end

          it 'returns valid' do
            expect(subject.valid?).to eq true
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

          it 'returns valid' do
            expect(subject.valid?).to eq true
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

        it 'returns valid' do
          expect(subject.valid?).to eq true
        end
      end
    end
  end

  context 'with invalid previous transactions' do
    let(:chargeback) { false }
    let(:transactions) { all_transactions }

    context 'when there are transaction in the last hour' do
      context 'when there is another transaction with same value in last hour' do
        let!(:same_value_transaction) do
          Transaction.create!(valid_attributes.merge(id: 21_320_222))
        end

        it 'returns invalid' do
          error = 'There is another transaction with same amount in the last hour'

          expect(subject).to_not be_valid
          expect(subject.errors[:base]).to eq [error]
        end
      end

      context "when the transactions' amount is equal as the one hour limit amount" do
        before do
          Transaction.create!({ id: 22_320_500,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: 40.minutes.ago,
                                amount: 1_000,
                                device_id: device_id })
        end

        it 'returns invalid' do
          error = "The transaction is over the User's one hour limit amount"

          expect(subject).to_not be_valid
          expect(subject.errors[:base]).to eq [error]
        end
      end

      context 'when there are more too many transactions in different devices in last hour' do
        before do
          Transaction.create!({ id: 22_320_500,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: 30.minutes.ago,
                                amount: 1.56,
                                device_id: device_id })

          Transaction.create!({ id: 22_320_300,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: 40.minutes.ago,
                                amount: 21.56,
                                device_id: device_id })
        end

        it 'returns invalid' do
          error = 'The User did too many transactions on this device in the last hour'

          expect(subject).to_not be_valid
          expect(subject.errors[:base]).to eq [error]
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
                                date: 30.minutes.ago,
                                amount: 1.56,
                                device_id: device_id_one })

          device_id_two = 555
          Device.create(id: device_id_two)
          Transaction.create!({ id: 22_320_300,
                                merchant_id: merchant_id,
                                user_id: user_id,
                                card_number: '434505******9116',
                                date: 40.minutes.ago,
                                amount: 543.56,
                                device_id: device_id_two })
        end

        it 'returns invalid' do
          error = 'The User did too many transactions on multiple devices in the last hour'

          expect(subject).to_not be_valid
          expect(subject.errors[:base]).to eq [error]
        end
      end
    end

    context "when there is one transaction with recommendation 'deny' for user" do
      let!(:transaction_denied) do
        Transaction.create!(valid_attributes.merge(id: 21_320_311, amount: 12.2,
                                                   recommendation: 'deny'))
      end

      it 'returns invalid' do
        error = 'There is another transaction denied for the User in the last hour'

        expect(subject).to_not be_valid
        expect(subject.errors[:base]).to eq [error]
      end
    end

    context 'when there is at least one chargeback for user' do
      let!(:chargeback) { true }

      it 'returns invalid' do
        error = 'There is another transaction with chargeback for the User'

        expect(subject).to_not be_valid
        expect(subject.errors[:base]).to eq [error]
      end
    end

    context "when the transactions' amount is equal the five hours limit amount" do
      before do
        Transaction.create!({ id: 22_320_500,
                              merchant_id: merchant_id,
                              user_id: user_id,
                              card_number: '434505******9116',
                              date: 3.hours.ago,
                              amount: 5_000,
                              device_id: device_id })
      end

      it 'returns invalid' do
        error = "The transaction is over the User's five hour limit amount"

        expect(subject).to_not be_valid
        expect(subject.errors[:base]).to eq [error]
      end
    end
  end
end

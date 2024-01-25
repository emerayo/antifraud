# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:device) }
    it { should belong_to(:user) }
    it { should belong_to(:merchant) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:card_number) }
  end

  describe 'enum' do
    it do
      should define_enum_for(:recommendation)
        .with_values(
          approve: 'approve',
          deny: 'deny'
        ).backed_by_column_of_type(:string)
    end
  end
end

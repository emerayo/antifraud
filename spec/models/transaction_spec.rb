# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:device) }
    it { should belong_to(:user) }
    it { should belong_to(:merchant) }
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:transactions).dependent(:restrict_with_exception) }
  end
end

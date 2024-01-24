# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :device
  belongs_to :merchant
  belongs_to :user
end

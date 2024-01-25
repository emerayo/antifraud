# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :device
  belongs_to :merchant
  belongs_to :user

  validates :amount, :date, :card_number, presence: true
  validates :amount, numericality: { greater_than: 0 }
end

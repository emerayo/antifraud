# frozen_string_literal: true

class Device < ApplicationRecord
  has_many :transactions, dependent: :restrict_with_exception
end

# frozen_string_literal: true

class TransactionNullChanges < ActiveRecord::Migration[7.0]
  def change
    change_column_null :transactions, :device_id, false
    change_column_null :transactions, :merchant_id, false
    change_column_null :transactions, :user_id, false

    change_column_null :transactions, :amount, false
    change_column_null :transactions, :date, false
    change_column_null :transactions, :card_number, false
  end
end

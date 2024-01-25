# frozen_string_literal: true

class AddCbkToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :has_cbk, :boolean, default: false, null: false
  end
end

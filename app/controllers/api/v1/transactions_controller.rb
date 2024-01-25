# frozen_string_literal: true

module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :find_transaction, only: :show

      # GET /transactions/:id
      def show
        render json: @transaction
      end

      # POST /transactions
      def create
        @transaction = Transaction.new(transaction_params)

        if @transaction.save
          render json: @transaction, status: :created
        else
          render json: { errors: @transaction.errors }, status: :unprocessable_entity
        end
      end

      private

      def find_transaction
        @transaction = Transaction.find(params[:id])
      end

      def transaction_params
        params.require(:transaction).permit(:id, :device_id, :merchant_id, :user_id,
                                            :amount, :card_number, :date)
      end
    end
  end
end

# frozen_string_literal: true

class RecommendationService
  APPROVE = 'approve'
  DENY = 'deny'

  def initialize(transaction:)
    @transaction = transaction
  end

  def run
    @transaction.recommendation = validate_recommendation ? APPROVE : DENY
    @transaction
  end

  private

  def validate_recommendation
    Recommendation.new(transaction: @transaction,
                       transactions: transactions,
                       chargeback: any_chargeback?).valid?
  end

  def transactions
    @transactions ||= Transaction.where(user_id: @transaction.user_id,
                                        date: 5.hours.ago..Time.current)
  end

  def any_chargeback?
    Transaction.exists?(user_id: @transaction.user_id, has_cbk: true)
  end
end

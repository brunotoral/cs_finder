# frozen_string_literal: true

require 'minitest/autorun'
require './lib/validations/schema'

class ValidationsSchemaTests < Minitest::Test
  class DummyClass
    include Validations::Schema

    def call(params)
      @customer_success = params[:customer_success]
      @customers = params[:customers]
      @away_customer_success = params[:away_customer_success]
    end

    attr_reader :customer_success, :customers, :away_customer_success
  end

  def setup
    @schema = DummyClass.new
    @valid_params = {
      customer_success: [
        { id: 1, score: 10 },
        { id: 2, score: 20 },
        { id: 3, score: 30 },
      ],
      customers: [
        { id: 1, score: 100 },
        { id: 2, score: 200 },
        { id: 3, score: 300 },
      ],
      away_customer_success: [],
    }
  end

  def test_valid_params
    @schema.call(@valid_params)
    assert_equal true, @schema.valid?
    assert_equal false, @schema.invalid?
  end

  def test_invalid_away_customer_success
    invalid_params = @valid_params.merge(away_customer_success: {})

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be an array', @schema.errors.messages[0].text
  end

  def test_invalid_customer_success_id_less_than_minimum
    invalid_params = @valid_params.merge(customer_success: [{ id: -1, score: 10 }])

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be greater than 0', @schema.errors.messages[0].text
  end

  def test_invalid_customer_success_score_less_than_minimum
    invalid_params = @valid_params.merge(customer_success: [{ id: 1, score: -10 }])

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be greater than 0', @schema.errors.messages[0].text
  end

  def test_invalid_customers_id_less_than_minimum
    invalid_params = @valid_params.merge(customers: [{ id: -1, score: 100 }])

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be greater than 0', @schema.errors.messages[0].text
  end

  def test_invalid_customers_score_less_than_minimum
    invalid_params = @valid_params.merge(customers: [{ id: 1, score: -100 }])

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be greater than 0', @schema.errors.messages[0].text
  end

  def test_invalid_customer_success_id_greater_than_limit
    invalid_params = @valid_params.merge(customer_success: [{ id: 1_000_001, score: 10 }])

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be less than 1000001', @schema.errors.messages[0].text
  end

  
  def test_invalid_customer_id_greater_than_limit
    invalid_params = @valid_params.merge(customers: [{ id: 10_001, score: 10 }])

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be less than 10001', @schema.errors.messages[0].text
  end

  def test_invalid_customer_success_score_greater_than_limit
    invalid_params = @valid_params.merge(customer_success: [{ id: 1, score: 10_001 }])

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be less than 10001', @schema.errors.messages[0].text
  end

  def test_invalid_customer_score_greater_than_limit
    invalid_params = @valid_params.merge(customers: [{ id: 1, score: 100_001 }])

    @schema.call(invalid_params)

    assert_equal true, @schema.invalid?

    assert_equal 'must be less than 100001', @schema.errors.messages[0].text
  end
end

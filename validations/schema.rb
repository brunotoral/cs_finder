# frozen_string_literal: true

require 'dry-schema'

module Validations
	module Schema
		class SchemaError < StandardError; end

		Schema = Dry::Schema.JSON do
			required(:customer_success).array(:hash) do
				required(:id).filled(:int?, gt?: 0, lt?: 1_000_001)
				required(:score).filled(:int?, gt?: 0, lt?: 10_001)
			end

			required(:customers).array(:hash) do
				required(:id).filled(:int?, gt?: 0, lt?: 10_001)
				required(:score).filled(:int?, gt?: 0, lt?: 100_001)
			end

			required(:away_customer_success).array(:integer)
		end

		def validate!
			raise SchemaError if invalid?
		end

		def invalid?
			!valid?
		end

		def valid?
			schema.success?
		end

		def errors
			schema.errors
		end

		private

		def schema
			Schema.call(params)
		end

		def params
			{ customer_success: customer_success, customers: customers, away_customer_success: away_customer_success }
		end
	end
end

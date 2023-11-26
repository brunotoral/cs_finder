# frozen_string_literal: true

require './lib/validations/schema'

class CustomerSuccessBalancing
	class CustomerSuccessNotFoundError < StandardError; end

	include Validations::Schema

	DEFAULT_RESPONSE = 0

	def initialize(customer_success, customers, away_customer_success)
		@customer_success = customer_success
		@customers = customers
		@away_customer_success = away_customer_success
	end

	def execute
		validate!

		top_customer_success_id
	
	rescue CustomerSuccessNotFoundError
		DEFAULT_RESPONSE
	end

	private

	attr_reader :customer_success, :customers, :away_customer_success

	def avaliable_cs
		@avaliable_cs ||= if away_customer_success.empty?
												customer_success
											else
												customer_success.reject { |cs| away_customer_success.include?(cs[:id]) }
											end
	end

	def top_customer_success_id
		grouped_customers = group_and_count_customer_by_cs
		assigned_customers_values = grouped_customers.values
		max_cs_by_score = grouped_customers.max_by { |_id, score| score }

		raise_not_found_error if invalid_response?(assigned_customers_values, grouped_customers, max_cs_by_score)

		max_cs_by_score.first
	end
	
	def invalid_response?(assigned_customers_values, grouped_customers, max_cs_by_score)
		is_draw?(max_cs_by_score.last, assigned_customers_values) || grouped_customers.empty?
	end

	def is_draw?(size, values)
		values.count(size) > 1
	end

	def group_and_count_customer_by_cs
		assigned_customers = Hash.new(0)
		previous_cs_score = 0

		sorted_avaliable_cs.each do |cs|
			customers_list = customers.select do |customer|
				customer[:score] <= cs[:score] && customer[:score] > previous_cs_score
			end

			previous_cs_score = cs[:score]

			assigned_customers[cs[:id]] += customers_list.size
		end

		assigned_customers
	end

	def sorted_avaliable_cs
		@sorted_avaliable_cs ||= avaliable_cs.sort_by { |cs| cs[:score] }
	end

	def validate!
		raise_not_found_error if avaliable_cs.empty?

		super
	end

	def raise_not_found_error
		raise CustomerSuccessNotFoundError
	end
end

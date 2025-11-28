module Tickets
  class Create < Base
    def initialize(params)
      @params = params
    end

    def call
      return Result.new(nil, []) unless customer

      ticket = customer.submitted_tickets.build(ticket_params)

      if ticket.save
        NotifyCustomerJob.perform_async(ticket.id)
        return Result.new(ticket, [])
      end

      Result.new(ticket, ticket.errors.full_messages)
    end

    private

    def customer
      @customer ||= Customer.find_by(id: params[:customer_id])
    end
  end
end

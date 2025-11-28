module Tickets
  class Update < Base
    attr_reader :ticket_id

    Result = Struct.new(:ticket, :errors)

    def initialize(ticket_id, params)
      @ticket_id = ticket_id
      @params = params
    end

    def call
      return Result.new(nil, []) unless ticket

      if ticket.update(ticket_params) && ticket.saved_change_to_customer_support_id?
        TicketAssignmentJob.perform_async(ticket_id)

        return Result.new(ticket, [])
      end

      Result.new(ticket, ticket.errors.full_messages)
    end

    private

    def ticket
      @ticket ||= Ticket.lock.find_by(id: ticket_id)
    end
  end
end

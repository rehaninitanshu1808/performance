module Tickets
  class Base
    attr_reader :params

    Result = Struct.new(:ticket, :errors)

    private

    def ticket_params
      params.slice(:subject, :description, :customer_id, :customer_support_id)
    end
  end
end

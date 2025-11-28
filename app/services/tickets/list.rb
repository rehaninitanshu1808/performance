module Tickets
  class List
    attr_reader :limit, :offset

    def initialize(limit, offset)
      @limit = limit
      @offset = offset
    end

    def call
      {
        tickets:,
        total_count:
      }
    end

    private

    def tickets
      Rails.cache.fetch(all_tickets_cache_key, expires_in: 5.minutes) do
        base_scope.to_a
      end
    end

    def total_count
      Rails.cache.fetch(tickets_count_cache_key, expires_in: 5.minutes) do
        base_scope.count
      end
    end

    def base_scope
      Ticket.offset(offset).limit(limit)
          .includes(:customer, :customer_support)
    end

    def all_tickets_cache_key
      [
        "tickets",
        limit,
        offset,
        Ticket.maximum(:updated_at)&.to_i
      ].join("/")
    end

    def tickets_count_cache_key
      [
        "tickets_count",
        limit,
        offset,
        Ticket.maximum(:updated_at)&.to_i
      ].join("/")
    end
  end
end

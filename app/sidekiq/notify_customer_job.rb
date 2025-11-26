class NotifyCustomerJob
  include Sidekiq::Job

  def perform(ticket_id)
    @ticket = Ticket.find_by!(id: ticket_id)

    CustomerMailer.ticket_creation(@ticket).deliver_now
  end
end

class TicketAssignmentJob
  include Sidekiq::Job

  def perform(ticket_id)
    ticket = Ticket.find_by!(id: ticket_id)

    CustomerMailer.assign_ticket(ticket).deliver_now
  end
end

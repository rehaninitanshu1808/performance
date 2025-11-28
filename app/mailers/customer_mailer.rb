class CustomerMailer < ApplicationMailer
  def ticket_creation(ticket)
    @ticket = ticket
    @customer = @ticket.customer

    mail(
      to: @customer.email,
      subject: "Your support ticket ##{@ticket.id} has been created"
    )
  end

  def assign_ticket(ticket)
    @ticket =  ticket
    @customer = @ticket.customer
    @customer_support = @ticket.customer_support

    mail(
      to: @customer.email,
      subject: "Your support ticket ##{@ticket.id} has been assigned"
    )
  end
end

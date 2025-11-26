class CustomerMailer < ApplicationMailer
  def ticket_creation(ticket)
    @ticket = ticket
    @customer = @ticket.customer

    mail(
      to: @customer.email,
      subject: "Your support ticket ##{@ticket.id} has been created"
    )
  end
end

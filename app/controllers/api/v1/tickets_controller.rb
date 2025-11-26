class Api::V1::TicketsController < ApplicationController
  include Pagination

  def index
    data = FetchTickets.new(per_page, offset).call
    @total_count = data[:total_count]

    render json: {
      tickets: ActiveModelSerializers::SerializableResource.new(
        data[:tickets],
        each_serializer: TicketSerializer
      ),
      pagination: page_details
    }
  end

  def create
    @ticket = customer.submitted_tickets.build(ticket_params)

    if @ticket.save
      NotifyCustomerJob.perform_async(@ticket.id)
      render json: @ticket, serializer: TicketSerializer, status: :created
    else
      render_error
    end
  end

  def update
    if ticket.update(ticket_params)
      render json: @ticket, serializer: TicketSerializer, status: :ok
    else
      render_error
    end
  end

  def destroy
    head :no_content if ticket.destroy!
  end

  private

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :customer_id, :customer_support_id)
  end

  def customer
    @customer = Customer.find_by!(id: ticket_params[:customer_id])
  end

  def ticket
    @ticket = Ticket.find_by!(id: params[:id])
  end

  def render_error
    render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_content
  end
end

class Api::V1::TicketsController < ApplicationController
  include Pagination

  def index
    data = Tickets::List.new(per_page, offset).call
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
    result = Tickets::Create.new(ticket_params.to_h).call

    if result.ticket.nil?
      render_error(status: :not_found)
    elsif result.errors.present?
      render_error(errors: result.errors)
    else
      render json: result.ticket, serializer: TicketSerializer, status: :created
    end
  end

  def update
    result = Tickets::Update.new(params[:id], ticket_params.to_h).call

    if result.ticket.nil?
      render_error(status: :not_found)
    elsif result.errors.present?
      render_error(errors: result.errors)
    else
      render json: result.ticket, serializer: TicketSerializer, status: :ok
    end
  end

  def destroy
    head :no_content if ticket.destroy!
  end

  private

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :customer_id, :customer_support_id)
  end

  def ticket
    @ticket = Ticket.find_by!(id: params[:id])
  end

  def render_error(errors: [], status: :unprocessable_content)
    render json: { errors: errors }, status: status
  end
end

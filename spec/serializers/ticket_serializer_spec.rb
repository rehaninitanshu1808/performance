require 'rails_helper'

RSpec.describe TicketSerializer do
  let(:customer) { FactoryBot.create(:customer) }
  let(:customer_support) { nil }
  let(:ticket) { FactoryBot.create(:ticket, customer:, customer_support:) }
  let(:customer_support_result) { nil }

  subject(:ticket_serializer) do
    described_class.new(ticket).as_json
  end

  let(:expected_result) do
    {
      id: ticket.id,
      subject: ticket.subject,
      description: ticket.description,
      status: ticket.status,
      customer: {
        id: customer.id,
        email: customer.email
      },
      customer_support: customer_support_result
    }
  end

  it { is_expected.to eql(expected_result) }

  describe "when customer support is present" do
    let(:customer_support) do
      FactoryBot.create(:customer_support)
    end

    let(:customer_support_result) {
      {
        id: customer_support.id,
        email: customer_support.email
      }
    }

    it { is_expected.to eql(expected_result) }
  end
end

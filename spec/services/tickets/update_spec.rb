require 'rails_helper'

RSpec.describe Tickets::Update do
  subject(:result) do
    described_class.new(ticket_id, params).call
  end

  let(:ticket) { create(:ticket) }
  let(:ticket_id) { ticket.id }
  let(:ticket_subject) { 'Ticket Subject' }

  let(:params) do
    {
      subject: ticket_subject
    }
  end

  describe '#call' do
    it 'updates the ticket', :aggregate_failures do
      result

      expect(ticket.reload.subject).to eql(ticket_subject)
    end

    context "when customer support id is present" do
      let(:customer_support_id) { create(:customer_support).id }

      let(:params) do
        {
          customer_support_id:
        }
      end

      before do
        Sidekiq::Testing.fake!
        allow(TicketAssignmentJob).to receive(:perform_async)
      end

      it 'updates the ticket with customer_support_id and triggers an email', :aggregate_failures do
        result

        expect(TicketAssignmentJob).to have_received(:perform_async)
        expect(ticket.reload.customer_support_id).to eql(customer_support_id)
      end
    end

    context "when ticket id is invalid" do
      let(:ticket_id) { 'x' }

      it 'returns nil' do
        expect(result.ticket).to eql(nil)
      end
    end

    context "when ticket params are invalid" do
      let(:ticket_subject) { nil }

      it 'returns errors' do
        expect(result.errors).to be_present
      end
    end

    context "when two worker update the ticket concurrently" do
      let(:params_one) { { subject: 'subject one' } }
      let(:params_two) { { subject: 'subject two' } }

      let(:threads) do
        [ params_one, params_two ].map do |params|
          Thread.new do
            described_class.new(ticket_id, params).call
          end
        end
      end

      before do
        allow(TicketAssignmentJob).to receive(:perform_async)
      end


      it "serializes updates through Ticket.lock and avoids race conditions", :aggregate_failures do
        threads.each(&:join)

        expect([ params_one[:subject], params_two[:subject] ]).to include(ticket.reload.subject)
        expect(TicketAssignmentJob).to have_received(:perform_async).at_most(:once)
      end
    end
  end
end

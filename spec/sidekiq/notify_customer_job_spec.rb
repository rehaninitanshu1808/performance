require 'rails_helper'

RSpec.describe NotifyCustomerJob, type: :job do
  subject(:perform_job) { described_class.new.perform(ticket_id) }

  let(:customer) { FactoryBot.create(:customer) }
  let(:ticket) { FactoryBot.create(:ticket, customer:) }
  let(:ticket_id) { ticket.id }

  before do
    mail_double = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    allow(CustomerMailer).to receive(:ticket_creation).with(ticket).and_return(mail_double)
  end

  context "when ticket id is valid" do
    it 'triggers an ticket creation email' do
      perform_job

      expect(CustomerMailer).to have_received(:ticket_creation).with(ticket)
    end
  end

  context "when ticket id is not valid" do
    let(:ticket_id) { 'xxx' }

    it 'raises a not found error' do
      expect { perform_job }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

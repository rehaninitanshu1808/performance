require "rails_helper"

RSpec.describe CustomerMailer, type: :mailer do
  describe "#ticket_creation" do
    let(:ticket) { create(:ticket, customer:) }
    let(:customer) { create(:customer) }

    subject(:mail) { described_class.ticket_creation(ticket) }

    it "renders the correct headers" do
      expect(mail.to).to eq([ customer.email ])
      expect(mail.subject).to eq("Your support ticket ##{ticket.id} has been created")
      expect(mail.from).to eq([ "from@example.com" ])
    end

    it "assigns @ticket and @customer" do
      expect(mail.body.encoded).to include(ticket.id.to_s)
      expect(mail.body.encoded).to include(customer.email)
    end

    it "delivers successfully" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end

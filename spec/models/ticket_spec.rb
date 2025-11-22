require 'rails_helper'

RSpec.describe Ticket, type: :model do

  describe "associations" do
    subject { described_class.new }

    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:customer_support).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:customer) }

    context "assignee_must_be_agent" do
      let!(:customer) { FactoryBot.create(:customer) }

      context "when customer support is not present" do
        subject { FactoryBot.build(:ticket, customer:).valid? }

        it { is_expected.to eql(true) }
      end

      context "when customer_support is present" do
        subject do
          FactoryBot.build(:ticket, customer: customer, customer_support: customer_support).valid?
        end

        context "when assignee is a customer support" do
          let(:customer_support) { FactoryBot.build(:customer_support) }

          it { is_expected.to eql(true) }
        end
      end
    end
  end
end

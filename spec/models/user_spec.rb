require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'attributes' do
    subject { described_class.new.attributes.keys }

    let(:expected_attributes) do
      %w(id email type created_at updated_at)
    end

    it { is_expected.to eql(expected_attributes) }
  end

  describe 'validations' do
    subject { FactoryBot.build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:type) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:submitted_tickets) }
  end
end

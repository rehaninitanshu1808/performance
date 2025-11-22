require 'rails_helper'

RSpec.describe CustomerSupport, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:assigned_tickets) }
  end
end

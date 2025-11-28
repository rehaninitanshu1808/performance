require 'rails_helper'
require "rspec-sqlimit"

RSpec.describe Tickets::List do
  subject(:list) do
    described_class.new(limit, offset).call
  end

  let(:offset) { 0 }
  let(:limit) { 10 }

  context "when tickets are present" do
    let!(:tickets) { create_list(:ticket, 5) }

    it 'returns the list', :aggregate_failures do
      expect { list }.not_to exceed_query_limit(5)
      expect(list[:tickets].size).to eql(5)
    end
  end
end

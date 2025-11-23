require 'rails_helper'

RSpec.describe "Api::V1::Tickets", type: :request do  
  describe "GET /index" do
    subject(:trigger_request) do
      get "/api/v1/tickets", params: { page: page }
    end

    let(:customer) { FactoryBot.create(:customer) }
    let(:json_response) { JSON.parse(response.body) }
    let(:page) { 1 }

    context "when tickets are present" do
      before do
        FactoryBot.create_list(:ticket, 2, customer: customer)
      end


      it 'verifies the response', :aggregate_failures do
        trigger_request

        expect(response).to have_http_status(:ok)
        expect(json_response['tickets']).to be_an(Array)
        expect(json_response['tickets'].size).to eql(2)
        expect(json_response['pagination']['total_pages']).to eql(1)
      end

      context "when request tickets on second page" do
        let(:page) { 2 }


        it 'verifies the response', :aggregate_failures do
          trigger_request

          expect(response).to have_http_status(:ok)
          expect(json_response['tickets']).to be_an(Array)
          expect(json_response['tickets'].size).to eql(0)
          expect(json_response['pagination']['total_pages']).to eql(0)
        end
      end
    end

    context "when tickets are not present", :aggregate_failures do
      it 'verifies the response' do
        trigger_request

        expect(response).to have_http_status(:ok)
        expect(json_response['tickets'].size).to eql(0)
      end
    end
  end

  describe "POST /create" do
    subject(:trigger_request) do
      post "/api/v1/tickets", params: ticket_params
    end

    let(:customer) do
      FactoryBot.create(:customer)
    end

    let(:ticket_params) do
      {
        "ticket": {
          "subject": 'Test',
          "description": "Test Description",
          "customer_id": customer.id
        }
      }
    end

    it "creates a ticket", :aggregate_failures do
      expect { trigger_request }.to change(Ticket, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end
end

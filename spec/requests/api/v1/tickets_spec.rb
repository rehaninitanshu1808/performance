require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe "Api::V1::Tickets", type: :request do
  describe "GET /index" do
    subject(:trigger_request) do
      get "/api/v1/tickets", params: { page: page }
    end

    let(:customer) { create(:customer) }
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

      context "when cache is expired", :aggregate_failures do
        it 'verifies the response' do
          trigger_request

          expect(response).to have_http_status(:ok)
          travel 6.minutes
          expect(Rails.cache.read("all_tickets")).to be_nil
        end
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
    before do
      Sidekiq::Testing.fake!
      allow(NotifyCustomerJob).to receive(:perform_async)
    end

    shared_examples "creates a ticket with valid params" do
      it "creates a ticket", :aggregate_failures do
        expect { trigger_request }.to change(Ticket, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(NotifyCustomerJob).to have_received(:perform_async)
      end
    end

    shared_examples "should not create a ticket with invalid params" do |status|
      it 'should not create a ticket' do
        expect { trigger_request }.not_to change(Ticket, :count)

        expect(response).to have_http_status(status)
        expect(NotifyCustomerJob).to_not have_received(:perform_async)
      end
    end

    subject(:trigger_request) do
      post "/api/v1/tickets", params: ticket_params
    end

    let(:customer_id) do
      FactoryBot.create(:customer).id
    end

    let(:customer_support_id) { nil }
    let(:subject) { 'subject' }

    let(:ticket_params) do
      {
        "ticket" => {
          "subject" => subject,
          "description" => "Test Description",
          "customer_id" => customer_id,
          "customer_support_id" => customer_support_id
        }
      }
    end

    context "when params are valid" do
      context "when customer_support_id is not present" do
        include_examples "creates a ticket with valid params"
      end

      context "when customer_support_id is present" do
        let(:customer_support_id) do
          FactoryBot.create(:customer_support).id
        end

        include_examples "creates a ticket with valid params"
      end
    end

    context "when params are not valid" do
      context "when customer id is not valid" do
        let(:customer_id) { 'x' }

        include_examples "should not create a ticket with invalid params", :not_found
      end

      context "when subject is not present" do
        let(:subject) { nil }

        include_examples "should not create a ticket with invalid params", :unprocessable_content
      end
    end
  end

  describe 'PUT /update' do
    subject(:trigger_request) do
      put "/api/v1/tickets/#{ticket_id}", params: ticket_params
    end

    let(:customer_support_id) { create(:customer_support).id }

    let(:ticket_params) do
      {
        "ticket" => {
          customer_support_id:
        }
      }
    end

    context "when ticket_id is not valid" do
      let(:ticket_id) { 'x' }

      it 'returns not found error', :aggregate_failures do
        trigger_request

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when params are valid" do
      let(:ticket) { create(:ticket) }
      let(:ticket_id) { ticket.id }

      it 'updates the ticket', :aggregate_failures do
        trigger_request

        expect(ticket.reload.customer_support_id).to eql(customer_support_id)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:ticket) { create(:ticket) }
    let(:ticket_id) { ticket.id }

    subject(:trigger_request) do
      delete "/api/v1/tickets/#{ticket_id}"
    end

    context "when ticket id is valid" do
      it "destroys the record", :aggregate_failures do
        trigger_request

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end

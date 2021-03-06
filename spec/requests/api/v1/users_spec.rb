require 'rails_helper'

describe 'Users API', type: [:request, :user]  do
  let!(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:headers) do
    {
      'Content-Type' => Mime[:json].to_s,
      'Authorization' => user.auth_token

    }
  end

  before { host! 'localhost' }

  describe "GET /api/v1/users/:id" do

    before do
      get "/api/v1/users/#{user_id}", params:{}, headers: headers
    end


    context "when the user exists" do
      it "returns the user" do
        expect(json_body[:id]).to eq(user_id)
      end

      it "return 200 status code" do
        expect(response).to have_http_status(:ok)
      end

    end

    context "when the user doesnt exists" do
      let(:user_id) { 1001 }

      it "return 404 status code" do
        expect(response).to have_http_status(:not_found)
      end

    end

  end

  describe "POST /api/v1/users" do

    before do
      post '/api/v1/users', params:{ user: user_params }.to_json, headers: headers
    end

    context "when request params are valid" do
      let(:user_params){ attributes_for(:user) }

      it "return status code 201" do
        expect(response).to have_http_status(:created)
      end

      it "return json data with created user" do
        expect(json_body[:email]).to eq(user_params[:email])
      end
    end

    context "when request params are not valid" do
      let(:user_params){ attributes_for(:user, email: 'invalid_email@') }

      it "return status code 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "return json data with errors" do
        expect(json_body).to have_key(:errors)
      end

    end

  end

  describe "PUT /api/v1/users/:id" do
    before do
      put "/api/v1/users/#{user_id}", params:{ user: user_params }.to_json, headers: headers
    end

    context "when request params are valid" do
      let(:user_params){ attributes_for(:user, email: 'new_email@taskmanager.com') }

      it "return status code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "return json data with created user" do
        expect(json_body[:email]).to eq(user_params[:email])
      end
    end

    context "when request params are not valid" do
      let(:user_params){ attributes_for(:user, email: 'invalid_email@') }

      it "return status code 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "return json data with errors" do
        expect(json_body).to have_key(:errors)
      end

    end
  end

  describe "DELETE /api/v1/users/:id" do

    before do
      delete "/api/v1/users/#{user_id}", params:{}, headers: headers
    end

    it "return status code 204" do
      expect(response).to have_http_status(:no_content)
    end

    it "removes user from database" do
      expect(User.find_by(id: user_id)).to be_nil
    end

  end
end

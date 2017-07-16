require 'spec_helper'

RSpec.describe Api::V1::SessionsController do
  describe 'POST #create' do
    before(:each) do
      @user = FactoryGirl.create :user
    end

    context 'when the credentials are correct' do
      before(:each) do
        credentials = { email: @user.email, password: '12345678' }
        post :create, params: { session: credentials }
      end

      it 'returns the user record corresponding to the given credentials' do
        @user.reload
        expect(json_response[:auth_token]).to eql @user.auth_token
      end

      it { should respond_with 200 }
    end

    context 'when the credentials are incorrect' do
      before(:each) do
        credentials = { email: @user.email, password: 'invalidpassword' }
        post :create, params: { session: credentials }
      end

      it 'returns a json with an error' do
        expect(json_response[:errors]).to eql 'Invalid email or password'
      end

      it { should respond_with 422 }
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryGirl.create :user
      sign_in @user
      delete :destroy, params: { id: @user.auth_token }
    end

    it { should respond_with 204 }
  end

  describe '#authenticate_with_token' do
    before do
      @user = FactoryGirl.create :user
      allow(authentication).to receive(:current_user).and_return(nil)
      allow(response).to receive(:response_code).and_return(401)
      allow(response).to receive(:body).and_return({ 'errors' => 'Not authenticated' }.to_json)
      allow(authentication).to receive(:response).and_return(response)
    end

    it 'render a json error message' do
      expect(json_response[:errors]).to eql 'Not authenticated'
    end

    it { should respond_with 401 }
  end
end

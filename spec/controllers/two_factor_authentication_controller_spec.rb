require 'spec_helper'

describe Devise::TwoFactorAuthenticationController, type: :controller do
  describe 'is_fully_authenticated? helper' do
    before do
      sign_in
    end

    context 'after user enters valid OTP code' do
      it 'returns true' do
        controller.current_user.send_new_otp
        post :update, code: controller.current_user.direct_otp
        expect(subject.is_fully_authenticated?).to eq true
      end
    end

    context 'when user has not entered any OTP yet' do
      it 'returns false' do
        get :show

        expect(subject.is_fully_authenticated?).to eq false
      end
    end

    context 'when user enters an invalid OTP' do
      it 'returns false' do
        post :update, code: '12345'

        expect(subject.is_fully_authenticated?).to eq false
      end
    end
  end

  describe 'redirect_if_authenticated' do
    before do
      sign_in
    end

    context 'after user enters valid OTP code' do
      before do
        controller.current_user.send_new_otp
        post :update, code: controller.current_user.direct_otp
      end

      it 'redirects away from authentication page' do
        get :show

        expect(response.code).to eq '302'
      end
    end

    context 'when user has not entered any OTP yet' do
      it 'does not redirect' do
        get :show

        expect(response.code).to eq '200'
      end
    end

    context 'when user enters an invalid OTP' do
      before do
        post :update, code: '12345'
      end

      it 'does not redirect' do
        get :show

        expect(response.code).to eq '200'
      end
    end
  end
end

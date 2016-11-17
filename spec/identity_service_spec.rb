require_relative 'spec_helper'
require "marketo"
require "yaml"

describe Marketo do
  describe Marketo::IdentityService do
    before(:context) do
      @identity_service = Marketo::IdentityService.new
    end

    describe 'authenticated?' do
      before do
        VCR.insert_cassette "authenticated", :record => :new_episodes
      end

      it 'should return false if no attempt has been made to authenticate' do
        expect(@identity_service.authenticated?).to be false
      end

      it 'should return false if the token has expired' do
        @identity_service.authenticate!
        expect(@identity_service.authenticated?).to be true

        Timecop.travel(Time.now + 3600) do
          expect(@identity_service.authenticated?).to be false
        end
      end

      it 'should return true if it has a valid, unexpired access token' do
        @identity_service.authenticate!
        expect(@identity_service.authenticated?).to be true
      end

      after do
        VCR.eject_cassette "authenticated"
      end
    end

    describe 'authenticate!' do
      before do
        VCR.insert_cassette "authenticate", :record => :new_episodes
      end

      it 'should request and return a new token' do
        token = @identity_service.authenticate!
        expect(token).to be
        expect(@identity_service.access_token).to be
      end

      it 'should bump the expiration' do
        Timecop.freeze(Time.now) do
          @identity_service.authenticate!
          expect(@identity_service.expiration).to be > Time.now
        end
      end
    end

    after do
      VCR.eject_cassette "authenticate"
    end
  end
end

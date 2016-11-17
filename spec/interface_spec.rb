require_relative "spec_helper"
require "marketo"
require "yaml"
require "erb"

describe Marketo::Interface do
  PROGRAM = "BASS Sync Testing"
  COOKIE = "id:572-ZRG-001&token:_mch-localhost-1306412206125-92040"
  USER = { "email" => "john@backupify.com", "firstName" => "john", "lastName" => "kelly", "company" => "Backupify" }
  USER_ID = 89381

  before(:context) do
    @config = Marketo.config

    @client = Faraday.new(url: @config.rest_endpoint)
    @identity_service = Marketo::IdentityService.new(@config)
    @interface = Marketo::Interface.new(@client, @identity_service)
  end

  describe "get_lead_by_id" do
    before do
      VCR.insert_cassette "get_lead_by_id", :record => :new_episodes
    end

    it "should get lead by id" do
      result = @interface.get_lead_by_id(USER_ID)
      expect(result["id"]).to eq(USER_ID)
    end

    it "should return error if no id is provided" do
      expect { @interface.get_lead_by_id(nil) }.to raise_exception(ArgumentError, "ID must be provided")
    end

    after do
      VCR.eject_cassette "get_lead_by_id"
    end
  end

  describe "get_lead_by_email" do
    before do
      VCR.insert_cassette "get_lead_by_email", :record => :new_episodes
    end

    it "should get lead by email" do
      result = @interface.get_lead_by_email(USER["email"])
      expect(result["email"]).to eq(USER["email"])
    end

    it "should return error if no email is provided" do
      expect { @interface.get_lead_by_email(nil) }.to raise_exception(ArgumentError, "Email must be provided")
    end

    after do
      VCR.eject_cassette "get_lead_by_email"
    end
  end

  describe "sync_lead" do
    before do
      VCR.insert_cassette "sync_lead", :record => :new_episodes
    end

    it "should sync lead with Marketo" do
      result = @interface.sync_lead(USER, PROGRAM, COOKIE)
      expected_result = [
        { "id" => 89381, "status" => "updated" }
      ]

      expect(result).to eq(expected_result)
    end

    it "should raise exception if no attributes passed" do
      err_text = "No attributes to sync"
      expect { @interface.sync_lead(nil, "program") }.to raise_exception(ArgumentError, err_text)
    end

    # it "should associate the lead with the cookie" do
    #   @interface.sync_lead(USER["email"], COOKIE, @attributes)
    #   lead = @interface.get_lead_by_email(USER["email"])
    #   binding.pry
    # end

    # it "should associate the lead with the program name" do
    #   @interface.sync_lead(USER["email"], COOKIE, @attributes)
    #   lead = @interface.get_lead_by_email(USER["email"])
    #   binding.pry
    # end

    after do
      VCR.eject_cassette "sync_lead"
    end
  end

  describe "sync_multiple" do
    before do
      VCR.insert_cassette "sync_multiple", :record => :new_episodes
    end

    it "should sync multiple leads with Marketo" do
      synced_users = [
        { "email" => "john@backupify.com", "firstName" => "john", "lastName" => "kelly" },
        { "email" => "admin@backupify.org", "firstName" => "Reed", "lastName" => "Richards" }
      ]
      expected_results = [
        { "id" => 89381, "status" => "updated" },
        { "id" => 2383499, "status" => "updated" }
      ]

      results = @interface.sync_multiple synced_users
      expect(results).to eq(expected_results)
    end

    it "should raise exception if empty array is passed" do
      err_text = "Empty leads hash, nothing to sync"
      expect { @interface.sync_multiple([]) }.to raise_exception(ArgumentError, err_text)
    end

    after do
      VCR.eject_cassette "sync_multiple"
    end
  end

  describe "authorization" do
    before do
      VCR.insert_cassette "authorization", :record => :new_episodes
    end

    it "should re-authorize before request if not authorized" do
      expect(@identity_service).to receive(:authenticated?) { false }

      expect(@identity_service).to receive(:authenticate!).and_call_original

      @interface.get_lead_by_id(USER_ID)
    end

    after do
      VCR.eject_cassette "authorization"
    end
  end

  describe "failure handling" do
    before do
      allow(@identity_service).to receive(:authenticated?) { true }
      @stubs = Faraday::Adapter::Test::Stubs.new
      stubbed_client = Faraday.new { |builder| builder.adapter :test, @stubs }
      @interface = Marketo::Interface.new(stubbed_client, @identity_service)
    end

    it "should return an APIError in the case of a non-200 HTTP response code" do
      @stubs.get("/rest/v1/leads/#{USER_ID}.json") { [500, {}, '{}'] }

      expect { @interface.get_lead_by_id(USER_ID) }.to raise_error(Marketo::ApiError)
    end

    it "should return an ApiError in the case of a non-successful Marketo response code" do
      body = JSON.generate({ "success" => false, "errors" => [{"code" => 607, "message" => "Daily quota reached"}] })
      @stubs.get("/rest/v1/leads/#{USER_ID}.json") { [200, {}, body] }

      expect { @interface.get_lead_by_id(USER_ID) }.to raise_error(Marketo::ApiError)
    end
  end
end

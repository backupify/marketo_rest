require_relative 'spec_helper'
require "marketo"
require "yaml"
require "erb"

describe Marketo do
  describe Marketo::Interface do
    IDNUM = 1000074
    EMAIL = "john@backupify.com"
    COOKIE = "id:572-ZRG-001&token:_mch-localhost-1306412206125-92040"
    USER = { :email => "john@backupify.com", :first_name => "john", :last_name => "kelly" }

    before(:all) do
      # To test:
      # Remove Timecop.freeze or setup Time.now.
      # Record VCR cassettes with actual responses from Marketo.
      # Setup Timecop with time of requests to eliminate 'Request expired' Error.
      Timecop.freeze(Time.parse('17 Dec 2013 18:59:40 GMT'))
      @interface = Marketo::Client.new_marketo_client
    end

    after(:all) do
      Timecop.return
    end

    describe 'Client timeouts' do
      it 'should set open timeout to 240 seconds' do
        @interface.client.http.open_timeout.should be_equal 240
      end

      it 'should set read timeout to 240 seconds' do
        @interface.client.http.read_timeout.should be_equal 240
      end
    end

    describe 'Exception handling' do
      before do
        VCR.insert_cassette "fault", :record => :new_episodes
      end

      it "should return error if no id is provided" do
        lambda { @interface.get_lead_by_id(nil) }.should raise_exception(Exception, "ID must be provided")
      end

      it "should return error if no email is provided" do
        lambda { @interface.get_lead_by_email(nil) }.should raise_exception(Exception, "Email must be provided")
      end

      it "should return SOAP fault if email is invalid" do
        lambda { @interface.get_lead_by_email("JUNK") }.should raise_exception(Savon::SOAP::Fault)
      end

      it "should return error if no email is provided on sync lead" do
        lambda { @interface.sync_lead(nil, "", {}) }.should raise_exception(Exception, "Email must be provided")
      end

      after do
        VCR.eject_cassette
      end
    end

    describe 'Lead' do
      before do
        VCR.insert_cassette "lead", :record => :new_episodes
      end

      it "should get lead by id" do
        lead_record = Marketo::Lead.new(nil, IDNUM)
        retVal = @interface.get_lead_by_id(IDNUM)
        retVal.should be_a_kind_of(Marketo::Lead)
        retVal.idnum.should == IDNUM
      end

      it "should get lead by email" do
        lead_record = Marketo::Lead.new(EMAIL)
        retVal = @interface.get_lead_by_email(EMAIL)
        retVal.should be_a_kind_of(Marketo::Lead)
        retVal.email.should == EMAIL
      end

      after do
        VCR.eject_cassette
      end
    end

    describe 'Sync' do
      before do
        VCR.insert_cassette "sync", :record => :new_episodes
      end

      it "should sync lead with Marketo" do
        retVal = @interface.sync_lead(USER[:email], COOKIE, { "FirstName"=>USER[:first_name],
                                                           "LastName"=>USER[:last_name],
                                                           "Company"=>"Backupify" })
        retVal.should be_a_kind_of(Marketo::Lead)
      end

      after do
        VCR.eject_cassette
      end
    end

    describe 'List' do
      before do
        VCR.insert_cassette "list", :record => :new_episodes
      end

      it "should add lead to marketo list" do
        @interface.add_lead_to_list(IDNUM, "Inbound Signups").should == true
      end

      after do
        VCR.eject_cassette
      end
    end

    describe "Multy sync" do
      before do
        VCR.insert_cassette "multy_sync", :record => :new_episodes
      end

      it "should sync multiple leads with Marketo" do
        multi_users = [
          { "Email" => "john@backupify.com", "FirstName" => "john", "LastName" => "kelly" },
          { "Email" => "admin@backupify.org", "FirstName" => "Reed", "LastName" => "Richards" }
        ]
        test_values = [
          {:lead_id=>"1000074", :status=>"UPDATED", :error=>nil},
          {:lead_id=>"1000085", :status=>"UPDATED", :error=>nil}
        ]

        response = @interface.sync_multiple multi_users

        response.should == test_values
      end

      it "should sync single lead and return array as result" do
        single_user = [{ "Email" => "admin@backupify.org", "FirstName" => "Reed", "LastName" => "Richards" }]
        test_value = [{:lead_id=>"1000085", :status=>"UPDATED", :error=>nil}]

        response = @interface.sync_multiple single_user
        response.should == test_value
      end

      it "should raise exception if empty array is passed" do
        err_text = "Empty leads hash, nothing to sync"
        lambda { @interface.sync_multiple(nil) }.should raise_exception(Exception, err_text)
      end

      after do
        VCR.eject_cassette
      end
    end

    describe 'to_hash' do
      it 'should update timestamp on every call to avoid request expiration' do
        @interface = Marketo::Client.new_marketo_client

        first_timestamp = @interface.instance_variable_get(:@header).to_hash["requestTimestamp"]
        Timecop.freeze(Time.now + 10)
        second_timestamp = @interface.instance_variable_get(:@header).to_hash["requestTimestamp"]

        first_timestamp.should_not == second_timestamp

        Timecop.return
      end
    end

    describe 'normalize_response' do
      it 'should return array if response is array' do
        response = [{:lead => 12345, :status => 'UPDATED', :error => nil},
                    {:lead => 12346, :status => 'SKIPPED', :error => 'Not uniq'}]

        @interface.send(:normalize_response, response).should == response
      end

      it 'should return one element array if response is hash' do
        response = {:lead => 12345, :status => 'UPDATED', :error => nil}
        @interface.send(:normalize_response, response).should == [response]
      end
    end
  end
end

ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Domain do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
    @chief_account = create(:chief_account)
    @admin_account = create(:admin_account)
  end
  let(:chief) { @chief_account.reload }
  let(:admin) { @admin_account.reload }
  after(:each) { Applyance::Server.db[:domains].delete }
  after(:all) do
    @chief_account.remove_all_roles
    @chief_account.destroy
    @admin_account.remove_all_roles
    @admin_account.destroy
  end

  def chief_auth
    header "Authorization", "ApplyanceLogin auth=#{chief.api_key}"
  end

  def admin_auth
    header "Authorization", "ApplyanceLogin auth=#{admin.api_key}"
  end

  shared_examples_for "a single domain" do
    it "returns the information for one domain" do
      expect(json.keys).to contain_exactly('id', 'name', 'created_at', 'updated_at')
    end
  end

  # Create domains
  describe "POST #domains" do
    context "logged in as chief" do
      before(:each) do
        chief_auth
        post "/domains", { name: "Retail" }
      end

      it_behaves_like "a single domain"
      it_behaves_like "a created object"
    end
    context "logged in as admin" do
      before(:each) do
        admin_auth
        post "/domains", { name: "Retail" }
      end

      it_behaves_like "an unauthorized account"
    end
    context "not logged in" do
      before(:each) { post "/domains", { name: "Retail" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve domains
  describe "GET #domains" do
    let!(:domains) { create_list(:domain, 3) }
    before(:each) { get "/domains" }

    it_behaves_like "a retrieved object"
    it "returns the number of domains" do
      expect(json.count).to eq(3)
    end
  end

  # Retrieve one domain
  describe "GET #domain" do
    let(:domain) { create(:domain) }
    before(:each) { get "/domains/#{domain.id}" }

    it_behaves_like "a single domain"
    it_behaves_like "a retrieved object"
  end

  # Update domain
  describe "PUT #domain" do
    context "logged in as chief" do
      let(:domain) { create(:domain) }
      before(:each) do
        chief_auth
        put "/domains/#{domain.id}", { name: "Retail 2" }
      end

      it_behaves_like "a single domain"
      it_behaves_like "a retrieved object"
      it "returns the updated name" do
        expect(json['name']).to eq('Retail 2')
      end
    end
    context "logged in as admin" do
      let(:domain) { create(:domain) }
      before(:each) do
        admin_auth
        put "/domains/#{domain.id}", { name: "Retail 2" }
      end

      it_behaves_like "an unauthorized account"
    end
    context "not logged in" do
      let(:domain) { create(:domain) }
      before(:each) { put "/domains/#{domain.id}", { name: "Retail 2" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove domain
  describe "Delete #domain" do
    context "logged in as chief" do
      let(:domain) { create(:domain) }
      before(:each) do
        chief_auth
        delete "/domains/#{domain.id}"
      end

      it_behaves_like "a deleted object"
    end
    context "logged in as admin" do
      let(:domain) { create(:domain) }
      before(:each) do
        admin_auth
        delete "/domains/#{domain.id}"
      end

      it_behaves_like "an unauthorized account"
    end
    context "not logged in" do
      let(:domain) { create(:domain) }
      before(:each) { delete "/domains/#{domain.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

end
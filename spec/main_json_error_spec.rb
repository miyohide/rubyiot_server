require File.join(File.dirname(__FILE__), "spec_helper")

RSpec.describe MainApp do
  include Rack::Test::Methods

  def app
    MainApp.new
  end

  describe "POST形式でデータ送信" do
    describe "空データの送信" do
      before do
        post "/api/sensor", nil
      end

      include_examples "return_status_code", 400
      include_examples "return_body_message", "No data is posted."
    end

    describe "JSON以外のデータ送信" do
      before do
        post "/api/sensor", "aaa"
      end

      include_examples "return_status_code", 400
      include_examples "return_body_message", "Posted JSON is invalid."
    end

    describe "ログイン情報なし" do
      before do
        post "/api/sensor", {}.to_json
      end

      include_examples "return_status_code", 403
      include_examples "return_body_message", "Not logged in."
    end

    describe "対応するAPIなし" do
      before do
        post "/api/aaaaaaaaaaaaaaaaaa", {}.to_json, { "rack.session" => { user_id: 1 } }
      end
      include_examples "return_status_code", 404
      include_examples "return_body_message", "Not Found"
    end
  end

  describe "GET /api/sensor" do
    describe "hardware_uid/gateway_idがPOSTデータにない" do
      before do
        get "/api/sensor", {}.to_json, { "rack.session" => { user_id: 1 }}
      end
      include_examples "return_status_code", 400
      include_examples "return_body_message", "Parameter hardware_uid or gateway_id is needed."
    end
  end

  describe "GET /api/controller" do
    describe "hardware_uid/gateway_idがPOSTデータにない" do
      before do
        get "/api/controller", {}.to_json, { "rack.session" => { user_id: 1 }}
      end
      include_examples "return_status_code", 400
      include_examples "return_body_message", "Parameter hardware_uid or gateway_id is needed."
    end
  end

  describe "GET /api/monitor" do
    describe "sensor_idがPOSTデータにない" do
      before do
        get "/api/monitor", {}.to_json, { "rack.session" => { user_id: 1 }}
      end
      include_examples "return_status_code", 400
      include_examples "return_body_message", "Parameter sensor_id is needed."
    end
  end

  describe "GET /api/sensor_data" do
    describe "sensor_idがPOSTデータにない" do
      before do
        get "/api/sensor_data", {}.to_json, { "rack.session" => { user_id: 1 }}
      end
      include_examples "return_status_code", 400
      include_examples "return_body_message", "Parameter sensor_id is needed."
    end
  end

  describe "GET /api/sensor_alert" do
    describe "sensor_idがPOSTデータにない" do
      before do
        get "/api/sensor_alert", {}.to_json, { "rack.session" => { user_id: 1 }}
      end
      include_examples "return_status_code", 400
      include_examples "return_body_message", "Parameter sensor_id is needed."
    end
  end

  describe "GET /api/operation" do
    describe "hardware_uid/gateway_idがPOSTデータにない" do
      before do
        get "/api/operation", {}.to_json, { "rack.session" => { user_id: 1 }}
      end
      include_examples "return_status_code", 400
      include_examples "return_body_message", "Parameter hardware_uid or gateway_id is needed."
    end
  end

  describe "GET /api/operation_status" do
    describe "hardware_uid/gateway_idがPOSTデータにない" do
      before do
        get "/api/operation_status", {}.to_json, { "rack.session" => { user_id: 1 }}
      end
      include_examples "return_status_code", 400
      include_examples "return_body_message", "Parameter operation_id is needed."
    end
  end
end

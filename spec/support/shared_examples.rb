RSpec.shared_examples "return_status_code" do |param|
  it "ステータスコードが#{param}であること" do
    expect(last_response.status).to eq(param)
  end
end

RSpec.shared_examples "return_body_message" do |param|
  it "メッセージが#{param}であること" do
    expect(last_response.body).to eq(param)
  end
end

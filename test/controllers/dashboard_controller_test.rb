require "test_helper"

describe DashboardController do
  it "should get index" do
    get dashboard_index_url
    value(response).must_be :success?
  end

end

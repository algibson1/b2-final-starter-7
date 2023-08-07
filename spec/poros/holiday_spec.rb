require "rails_helper"

RSpec.describe Holiday do
  before do
    @holiday_hash = {
      "date" => "2023-09-04",
      "localName" => "Labor Day",
      "name" => "Labour Day",
      "countryCode" => "US",
      "fixed" => false,
      "global" => true,
      "counties" => nil,
      "launchYear" => nil,
      "types" => [
        "Public"
      ]
    }
  end

  it "exists and has a name and date" do
    holiday = Holiday.new(@holiday_hash)
    expect(holiday).to be_a(Holiday)
    expect(holiday.name).to eq("Labor Day")
    expect(holiday.date).to eq("Monday, September 4, 2023")
  end
end
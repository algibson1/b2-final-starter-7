require "rails_helper"

RSpec.describe HolidayService do
  it "can access the NAGER date API" do
    response = HolidayService.new.connection
    holiday_hashes = JSON.parse(response.body)
    expect(holiday_hashes).to be_a(Array)
    expect(holiday_hashes).to all be_a(Hash)
  end

  it "can generate holidays" do
    holidays = HolidayService.new.make_holidays
    expect(holidays).to be_a(Array)
    expect(holidays).to all be_a(Holiday)
  end

  it "returns next three holidays" do
    holidays = HolidayService.new.next_3_holidays
    expect(holidays.size).to eq(3)
    dates = holidays.map {|holiday| holiday.date.to_date}

    expect(Date.today < dates[0]).to eq(true)
    expect(dates[0] < dates[1]).to eq(true)
    expect(dates[1] < dates[2]).to eq(true)
  end
end

class HolidayService
  def make_holidays
    response = JSON.parse(connection.body)
    response.map { |hash| Holiday.new(hash)}
  end
  
  def next_3_holidays
    make_holidays[0..2]
  end
  
  def connection 
    HTTParty.get("https://date.nager.at/api/v3/NextPublicHolidays/US")
  end

end
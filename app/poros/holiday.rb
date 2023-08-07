class Holiday
  attr_reader :name,
              :date
  def initialize(data)
    @name = data["localName"]
    @date = data["date"].to_date.strftime("%A, %B %-d, %Y")
  end
end
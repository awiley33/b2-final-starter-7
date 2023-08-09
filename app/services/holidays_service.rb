
class HolidaysService
  def self.upcoming_holidays
    url = 'https://date.nager.at/api/v3/NextPublicHolidays/US'
    response = Faraday.get(url)
    parsed_holidays = JSON.parse(response.body)
    holidays = parsed_holidays.map{ |holiday_details| Holiday.new(holiday_details) }
    holidays.first(3)
  end
end
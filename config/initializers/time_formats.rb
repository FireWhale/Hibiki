# Be sure to restart your server when you modify this file.

#Custom formats for albums/artists.
Date::DATE_FORMATS[:month_and_year] = "%B %Y"
Date::DATE_FORMATS[:month_and_day] = "%B %d"

#Gets rid of milliseconds - useful for JSON testing (which uses to.json)
ActiveSupport::JSON::Encoding.time_precision = 0

module UsersHelper
  
  def languagehelper(language)
    #This is a really dumb helper for a case-by-case basis for humanizing language
    if language == "RomanizedKorean"
      "Romanized Korean"
    elsif language == "Romaji"
      "Romaji (Romanized Japanese)"
    elsif language == "Korean"
      "Korean (Hangul)"
    elsif language == "Japanese"
      "Japanese (Kanji/Hiragana)"
    else
      language
    end
  end
end

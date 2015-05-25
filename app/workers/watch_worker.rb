class WatchWorker
  include Sidekiq::Worker
  
  def perform
    #Get to the url and grab a list of all the recent changes
      agent = Mechanize.new
    #Album changes
      url = "http://vgmdb.net/db/recent.php"
      agent.get(url)
      doc = agent.page.parser
      albumlinks = doc.xpath("//a[contains(@class,'albumtitle')]").map {|album| album['href']}.uniq
    #Scan Changes
      url = "http://vgmdb.net/db/recent.php?do=view_scans"
      agent.get(url)
      doc = agent.page.parser
      scanlinks = doc.xpath("//tr/td[1]/a").map { |image| "http://vgmdb.net" + image['href']}.uniq
    #product changes
      url = "http://vgmdb.net/db/recent.php?do=view_products"
      agent.get(url)
      doc = agent.page.parser
      productlinks = doc.xpath("//tr/td[1]/a").map { |image| "http://vgmdb.net" + image['href']}.uniq
    #Join and uniq all the links
      links = (albumlinks + scanlinks + productlinks).uniq
    #For each album, search for it in our database
      links.each do |link|
        #Search for it using sunspot
        albumresults = Album.search  do
          fulltext link do
            fields(:reference)
          end
        end
        unless albumresults.results.empty?
          album = albumresults.results.first
          album.tags << Tag.find(50) unless album.tags.map(&:id).include?(50) #Tag 50 is the update available tag
        end
      end
  end
end

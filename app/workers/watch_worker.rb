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
          fulltext link
        end
        if albumresults.results.empty? == false
          album = albumresults.results.first
          #Make sure the url matches the reference
          if album.reference[:VGMdb] != link
            if album.privateinfo.starts_with?("UPDATE AVAILABLE:") == false
              album.privateinfo = "UPDATE AVAILABLE: " + Time.now.to_s + " - Check Reference \n\n" + album.privateinfo
              album.save
            end
          else
            if album.privateinfo.starts_with?("UPDATE AVAILABLE:") == false
              album.privateinfo = "UPDATE AVAILABLE: " + Time.now.to_s + "\n\n" + album.privateinfo
              album.save
            end
          end
        end
      end
  end
end

class WatchWorker
  include Sidekiq::Worker
  
  def perform
    @album_links, @scan_links, @product_links = [], [], []
    
    url_scan("http://vgmdb.net/db/recent.php", @album_links, "album")
    url_scan("http://vgmdb.net/db/recent.php?do=view_scans", @scan_links, "scan")
    url_scan("http://vgmdb.net/db/recent.php?do=view_products", @product_links, "scan")
    
    links = (@album_links + @scan_links + @product_links).uniq
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
  
  def retry_url_watch(url, links, type)
    agent = Mechanize.new 
    attempts = 0
    begin
      agent.get(url)
      doc = agent.page.parser
      if type == "album"
        links = doc.xpath("//a[contains(@class,'albumtitle')]").map {|album| album['href']}.uniq        
      else
        links = doc.xpath("//tr/td[1]/a").map { |image| "http://vgmdb.net" + image['href']}.uniq
      end
    rescue Net::HTTP::Persistent::Error
      logger.warn "Hit persistent error. Retrying"
      retry if attempts < 3
      logger.warn "Hit maximum retries. Skipping url."
    end
  end
end

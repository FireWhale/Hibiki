require "net/http"

class WatchWorker
  include Sidekiq::Worker
  
  def perform    
    @album_links = url_scan("http://vgmdb.net/db/recent.php", "album")
    @scan_links = url_scan("http://vgmdb.net/db/recent.php?do=view_scans", "scan")
    @product_links = url_scan("http://vgmdb.net/db/recent.php?do=view_products", "product")
    
    links = (@album_links + @scan_links + @product_links).uniq
    #For each album, search for it in our database
      links.each do |link|
        #Search for the reference
        reference = Reference.find_by_url(link)
        unless reference.nil?
          album = reference.model
          album.tags << Tag.find(50) unless album.tags.map(&:id).include?(50) #Tag 50 is the update available tag
        end
      end
  end
  
  def url_scan(url, type)
    links = []
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
      logger.warn "Successfully retried #{type}" if attempts > 0
    rescue Net::HTTP::Persistent::Error
      logger.warn "Hit persistent error on #{type}. Retrying"
      retry if attempts < 3
      logger.warn "Hit maximum retries. Skipping #{type}."
    end
    links
  end
end

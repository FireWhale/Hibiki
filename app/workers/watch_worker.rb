require "net/http"

class WatchWorker
  include Sidekiq::Worker
  
  sidekiq_options expires_in: 3.hours
  
  def perform    
    @album_links = url_scan("http://vgmdb.net/db/recent.php", "recent albums")
    @scan_links = url_scan("http://vgmdb.net/db/recent.php?do=view_scans", "scan")
    @product_links = url_scan("http://vgmdb.net/db/recent.php?do=view_products", "product")
    
    links = (@album_links + @scan_links + @product_links).uniq
    edit_count = 0
    #For each album, search for it in our database
    links.each do |link|
      #Search for the reference
      reference = Reference.find_by_url(link)
      unless reference.nil?
        album = reference.model
        unless album.tags.map(&:id).include?(50)
          album.tags << Tag.find(50)  #Tag 50 is the update available tag
          edit_count += 1
        end
      end
    end
    logger.info "Updated #{edit_count} albums"
  end
  
  def url_scan(url, type)
    links = []
    agent = Mechanize.new 
    attempts = 0
    begin
      agent.get(url)
      doc = agent.page.parser
      if type == "recent album"
        links = doc.xpath("//a[contains(@class,'albumtitle')]").map {|album| album['href']}.uniq        
      else
        links = doc.xpath("//tr/td[1]/a").map { |image| "http://vgmdb.net" + image['href']}.uniq
      end
      logger.warn "Successfully retried #{type}" if attempts > 0
    rescue Net::HTTP::Persistent::Error
      logger.warn "Hit persistent error on #{type}. Retry ##{attempts}"
      retry if attempts < 3
      logger.warn "Hit maximum retries. Skipping #{type}."
    rescue SocketError
      logger.warn "Got socket Error. Internet down?. Retry ##{attempts}"
      retry if attempts < 3
      logger.warn "Hit maximum retries. Skipping #{type}."
    end
    links
  end
end

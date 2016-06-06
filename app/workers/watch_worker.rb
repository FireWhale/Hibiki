require "net/http"

class WatchWorker
  include Sidekiq::Worker

  sidekiq_options expires_in: 3.hours

  def perform
    @log = Log.where(category: "Watch Scrape").last
    if @log.nil?
      @log = Log.create(category: "Watch Scrape", content: "[New Log] No previous log found!")
    else
      if @log.content.length > 5000
        @log.add_to_content("[End Log] Content length limit reached at #{Time.now}")
        @log = Log.create(category: "Watch Scrape", content: "[New Log] Content length reached on old log")
      end
    end

    @log.add_to_content("\n[Start]Checking for updates at #{Time.now}")

    album_links = url_scan("http://vgmdb.net/db/recent.php", "recent albums")
    scan_links = url_scan("http://vgmdb.net/db/recent.php?do=view_scans", "scan")
    product_links = url_scan("http://vgmdb.net/db/recent.php?do=view_products", "product")

    links = (album_links + scan_links + product_links).uniq
    edit_count = 0
    links.each do |link|
      reference = Reference.find_by_url(link)
      unless reference.nil?
        album = reference.model
        update_tag = Tag.find_by_internal_name("Update Available") #Tag 50
        unless album.tags.include?(update_tag)
          album.tags << update_tag
          edit_count += 1
          @log.albums << album
        end
      end
    end
    logger.info "Updated #{edit_count} albums"
    @log.add_to_content("\n[End]Finished at #{Time.now}. New updates available for #{edit_count} albums")
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
      attempts += 1
      logger.warn "Hit persistent error on #{type}. Retry ##{attempts}"
      retry if attempts < 20
      logger.warn "Hit maximum retries. Skipping #{type}."
      @log.add_to_content "\n[Error]Failed to grab #{type} due to persistent error."
    rescue SocketError
      attempts += 1
      logger.warn "Got socket Error on #{type}. Retry ##{attempts}"
      retry if attempts < 20
      logger.warn "Hit maximum retries. Skipping #{type}."
      @log.add_to_content "\n[Error]Failed to grab #{type} due to socket error"
    end
    return links
  end
end

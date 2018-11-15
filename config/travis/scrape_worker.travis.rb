class ScrapeWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(input, options = {})

  end
end
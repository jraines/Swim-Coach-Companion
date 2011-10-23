require 'open-uri'

class  MeetSummary < Sinatra::Base

  get '/' do
    "URL: <form action='parse' method='post'><input type='text' name='url' /><input type='submit' /></form>"
  end

  post '/parse' do
    page = get_page( params[:url] )
    @team = params[:team]
    event_pages = get_event_links( page )
    @blocks = scrape_event_pages( event_pages )
    haml :results
  end


  helpers do
      
    def scrape_results(url, team)
      `curl #{url} | grep #{team}`.split(/\n/)
    end

    def get_page(url)
      url += '/' unless url[/\/$/]
      event_list_path = 'evtindex.htm'
      event_list_url = url + event_list_path
      Nokogiri::HTML(open(event_list_url))
    end

    def scrape_event_pages(pages)
      pages.each do |page|
        event_url = url + page[:path]
        @blocks << {:event => page[:event], :results => scrape_results(event_url, team)}
      end
    end

    def get_event_links(page)
      links = page.xpath '//a'
      event_links = links.collect {|l| l if l.text[/^#/]}
      event_links.compact!
      event_links.map { |l| { :event => l.text, :path => l.attributes['href'].value } }
    end

  end

end

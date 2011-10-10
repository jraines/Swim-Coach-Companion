require 'open-uri'

class  MeetSummary < Sinatra::Base

  get '/' do
    "URL: <form action='parse' method='post'><input type='text' name='url' /><input type='submit' /></form>"
  end

  get '/test' do
    " fhfhf \n fjfjfjf \n fa     aa \n"
  end

  post '/parse' do
    url = params[:url]
    debugger
    url += '/' unless url[/\/$/]
    event_list_path = 'evtindex.htm'
    event_list_url = url + event_list_path
    doc = Nokogiri::HTML(open(event_list_url))
    links = doc.xpath '//a'
    event_links = links.collect {|l| l if l.text[/^#/]}
    event_links.compact!
    el = event_links.map do |l| 
      { :event => l.text, :path => l.attributes['href'].value }
    end
    @blocks = []
    el.each do |el|
      event_url = url + el[:path]
      @blocks << {:event => el[:event], :results => `curl #{event_url} | grep CSSC-CA`.split(/\n/)}
    end
    @blocks
    haml :results
  end

end

require 'open-uri'

Result = Struct.new :place, :swimmer, :age, :team, :seed, :time

class ResultTextParser
  def self.parse(lines)
    results = []
    lines = lines.split /\n/
    lines.each do |line|
      arr = line.strip.split /\s+/
      place = arr.shift
      swimmer = [].tap {|sw| sw << arr.shift until arr.first[/\d/] }.join
      age, team, seed, time = *arr[0..3]
      results << Result.new( place, swimmer, age, team, seed, time )
    end
    results
  end
end


class EventPage
  attr_accessor :name

  def initialize(name, url)
    @name, @url = name, url
  end

  def results_for_team(team)
    results_text = `curl -s #{@url} | grep #{team} | grep -v Hosted `
    results = ResultTextParser.parse( results_text )
  end

end


class ResultSite

  ResultBlock = Struct.new(:event, :results)

  EVENT_LIST_PATH = 'evtindex.htm'

  def initialize( url )
    @url  = parse_url(url)
    @page = get_page
    @event_pages = get_event_pages( @page )
  end

  def parse_url( url )
    url += '/' unless url[/\/$/]
    url
  end

  def results_for_team( team )
    [].tap do |results|
      @event_pages.each do |page| 
        results << ResultBlock.new( page.name, page.results_for_team(team) ) #ResultBlock.results will be an array of Results
      end
    end
  end

  def get_page
    event_list_url = @url + EVENT_LIST_PATH
    Nokogiri::HTML(open(event_list_url))
  end

  def get_event_pages(page)
    links = page.xpath '//a'
    event_links = links.collect {|l| l if l.text[/^#/]}
    event_links.compact!
    event_links.map { |l| EventPage.new(l.text, @url + l.attributes['href'].value) }
  end


end

class  MeetSummary < Sinatra::Base

  get '/' do
    haml :index
  end

  post '/parse' do
    url, team = params[:url], params[:team]
    @blocks = ResultSite.new( url ).results_for_team( team )
    haml :results
  end

end

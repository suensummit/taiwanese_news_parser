class TaiwaneseNewsParser::Parser::ChinaTimes < TaiwaneseNewsParser::Parser
  def self.domain
    'chinatimes.com'
  end

  def set_doc(url)
    @raw = open(url).read
    @doc = Nokogiri::HTML(@raw)
  end

  #url = 'http://news.chinatimes.com/mainland/11050505/112013041400325.html'
  def parse
    @article[:title] = @doc.at_css('header h1').text

    @article[:company_name] = @doc.at_css('.reporter>a').text
    if @article[:company_name] == '新聞速報'
      @article[:company_name] = nil
    end

    @article[:content] = @doc.css('.page_container article>p').text

    #@article[:web_published_at] = Time.parse(@doc.at_css('#story_update').text)

    @article[:reporter_name] = parse_reporter_name()

    t = @doc.css('.reporter time').text.match(/(\d*)年(\d*)月(\d*)日 (\d*):(\d*)/)
    @article[:published_at] = Time.new(t[1],t[2],t[3],t[4],t[5])

    clean_up

    @article
  end

  def parse_reporter_name
    text = @doc.css('.reporter>text()').text
    if match = text.match(%r{記者(.+?)[/／╱／]})
      reporter_name = match[1]
    elsif match = text.match(%r{【(.+?)[/／╱／]})
      reporter_name = match[1]
    else
      reporter_name = text
    end
    reporter_name
  end

  def clean_url
    cleaner = TaiwaneseNewsParser::UrlCleaner.new('id')
    @article[:url] = cleaner.clean(@article[:url])
  end

  def reproduced?
    @doc.css('.reporter>a').text.include?('中央社')
  end

  def self.parse_url_id(url)
    url[%r{http://news.chinatimes.com/\w+/(\d+/\d+)},1]
  end
end

require "url_common/version"
require 'fuzzyurl'
require 'mechanize'
require 'ostruct'

module UrlCommon
  class Error < StandardError; end
  
  # UrlCommon.is_valid?("http://fuzzyblog.io/blog/")
  # UrlCommon.is_valid?("fuzzyblog.io/blog/")
  def self.is_valid?(url)
    begin
      result = Fuzzyurl.from_string(url)
      return false if result.hostname.nil?
      return false if result.protocol.nil?
      return false if (!result.hostname.include?('.')) && result.protocol.nil?
      return true
    rescue StandardError => e
      return false
    end
  end
  
  # UrlCommon.parse_fid_from_itunes_url("https://itunes.apple.com/us/app/imovie/id408981434?mt=12")
  def self.parse_fid_from_itunes_url(url)
    tmp = /\/id([0-9]+)/.match(url)
    if tmp && tmp[1]
      return tmp[1] 
    else
      return nil
    end
  end
  
  def self.parse_country_from_itunes_url(url)
    country = /https?:\/\/itunes\.apple\.com\/(..)\//.match(url)
    if country
      country = country[1] 
    end
    return country if country
    return 'us'
  end
  
  def self.get_base_domain(url)
    parts = URI.parse(url)
    return parts.host.gsub(/^www./,'')
  end
  
  def self.join(base, rest, debug = false)
    return URI.join(base, rest).to_s
  end
  
  def self.url_no_www(url)
    parts = Fuzzyurl.new(url)
    if parts.query
      #return parts.hostname.sub(/^www\./, '') + parts.try(:path) + '?' + parts.query 
      return parts.hostname.sub(/^www\./, '') + parts&.path + '?' + parts.query 
    else
      #byebug
      #return parts.hostname.sub(/^www\./, '') + parts.try(:path).to_s
      return parts.hostname.sub(/^www\./, '') + parts&.path.to_s
    end
  end
  
  #TODO
  def self.count_links(html)
    return 0
  end
  
  def self.agent
    return Mechanize.new
  end
  
  def self.strip_a_tag(a_tag)
    #<a href="https://www.keyingredient.com/recipes/12194051/egg-salad-best-ever-creamy/">
    return a_tag.sub(/<a href=[\"']/,'').sub(/[\"']>/,'')
  end
  

  #
  # Returns a url w/o http://wwww 
  # UrlCommon.url_base("https://www.udemy.com/the-build-a-saas-app-with-flask-course/")
  # "udemy.com/the-build-a-saas-app-with-flask-course/"
  #
  def self.url_base(url, base_domain=nil)
    if base_domain.nil?
      base_domain = get_base_domain(url)
    end
    parts = URI.parse(url)
    extra = ""
    extra = "?#{parts.query}" if parts.query
    url_base = "#{base_domain}#{parts.path}#{extra}"
    return url_base[0..254]
  end
  
  #tested #https://www.amazon.com/gp/product/B01DT4A2R4/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&tag=nickjanetakis-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01DT4A2R4&linkId=496be5e222b6291369c0a393c797c2c0
  # returns nil if link isn't amazon at all
  # returns true if link is amazon and has referrer code
  # returns false if link is amazon and doesn't have referrer code
  def self.check_for_amazon_referrer(url, referrer_code)
  #def check_for_amazon_referrer(url, referrer_code)
    #https://github.com/gamache/fuzzyurl.rb
    fu = Fuzzyurl.from_string(url)
    return nil if fu.hostname.nil? 
    base_domain = fu.hostname.sub(/^www./,'')
    # base_domain = UrlCommon.get_base_domain
    parts = base_domain.split(".")
    return nil if parts[0] != "amazon"
    #referer_code = self.account.user.details[:amazon_referrer_code]
    if url =~ /#{referrer_code}/
      return true
    else
      return false
    end
  end
  
  # TODO needs tests  
  #def self.check_for_jekyll_subdomain?(url)
  def self.has_own_domain?(url)
    return false if url =~ /\.github\.io/
    return false if url =~ /\.blogspot\.com/
    return false if url =~ /\.wordpress\.com/
    #return false if url =~ /\..+\./
    return true
    if site_url =~ /\..+\./
      return true
    else
      analysis_results << "You have a domain of your own; that's a great first step!"
    end
  
  end
  
  # TODO needs tests  
  def self.get_page(url, return_html = false, user_agent = nil)
    agent = Mechanize.new { |a| 
      if user_agent.nil?
        #a.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:46.0) Gecko/20100101 Firefox/46.0"
        a.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36"
      else
        a.user_agent = user_agent
      end
      #a.user_agent = "curl/7.54.0"
      #debugger
    }
    agent.verify_callback = Proc.new do |ok,x509|
      status = x509.error
      msg = x509.error_string
      logger.warn "server certificate verify: status: #{status}, msg: #{msg}" if status != 0
      true # this has the side effect of ignoring errors. nice!
    end 
    begin
      page = agent.get(url)
      if return_html
        return :ok, page.body
      else
        return :ok, page
      end
      #return :ok, page
    rescue StandardError => e
      return :error, e
    end
  end
  
  # def self.get_page_caching_attempt(url, return_html = false)
  #   agent = Mechanize.new { |a|
  #     a.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:46.0) Gecko/20100101 Firefox/46.0"
  #   }
  #   agent.verify_callback = Proc.new do |ok,x509|
  #     status = x509.error
  #     msg = x509.error_string
  #     logger.warn "server certificate verify: status: #{status}, msg: #{msg}" if status != 0
  #     true # this has the side effect of ignoring errors. nice!
  #   end
  #   begin
  #     page = agent.get(url)
  #     if return_html
  #       Rails.cache.fetch(UrlCommon.sha_it(url), :expires_in => 1.hour) do
  #         page.body
  #       end
  #       # Rails.cache.fetch(UrlCommon.sha_it(url), :expires_in => 1.hour) do
  #       #   debugger
  #       #   page.body
  #       # end
  #       return :ok, page.body
  #     else
  #       return :ok, page
  #     end
  #   rescue StandardError => e
  #     return :error, e
  #   end
  # end
  
  def self.mpage_is_html?(page)
    return true if page.respond_to?(:title)
    return false
  end
  
  # TODO needs tests  
  def self.check_for_404(url, elixir_style = false)
    agent = Mechanize.new
    results = []
  
    begin
      head_result = agent.head(url)
      return OpenStruct.new(:url => url, :status => 200) if elixir_style == false
      return :ok, url if elixir_style
    rescue StandardError => e
      if e.to_s =~ /404/
        return OpenStruct.new(:url => url, :error => e, :status => 404)
      else
        return OpenStruct.new(:url => url, :error => e, :status => 404)        
      end
    end
  end

  # TODO needs tests
  def self.check_for_broken_links(links)
    results = []
    agent = Mechanize.new
    links.each do |link|
      begin
        result = agent.head(link.href)
        results << OpenStruct.new(:url => link.href, :status => 200)
      rescue StandardError => e
        if e.to_s =~ /404/
          results << OpenStruct.new(:url => link.href, :error => e, :status => 404)
        end
      end
    end
    #debugger
    results
  end
  
  def self.fix_relative_url(base_url, partial_url)
    return partial_url if partial_url =~ /^http/
    parts = URI.parse(base_url)
    return parts.scheme + '://' +  parts.host + partial_url
    return File.join(base_url, partial_url)
  end
    
  # status, url = UrlCommon.validate_with_merge_fragment("nickjj/orats", "https://www.github.com/")
  def self.validate_with_merge_fragment(url, merge_fragment)
    #
    # verify it is a valid url and it isn't a 404 or redirect
    #
    if is_valid?(url) && check_for_404(url)
      return true, url 
    end
  
    #
    # Try and make it valid
    #
    if url =~ /^http/
      # if its invalid and has http then don't know what to do so return false
      return false, url
    end
  
    url = File.join(merge_fragment, url)
    if is_valid?(url) && check_for_404(url)
      return true, url
    end        
  end
  
  #TODO needs tests
  def self.create_mechanize_page_from_html(url, html)
    mechanize_page = Mechanize::Page.new(nil, {'content-type'=>'text/html'}, html, nil, Mechanize.new)
    mechanize_page.uri = URI.parse(url)    
  
    return mechanize_page
  end
end

RSpec.describe UrlCommon do
  it "has a version number" do
    expect(UrlCommon::VERSION).not_to be nil
  end
  
  describe ".is_valid?" do
    it "should return true when a link is valid" do
      expect(UrlCommon.is_valid?("http://fuzzyblog.io/blog/")).to be_truthy
    end

    it "should return false when a link is not valid" do
      expect(UrlCommon.is_valid?("/fuzzyblog.io/blog/")).to be_falsey
    end
  end
  
  describe ".parse_fid_from_itunes_url" do
    it "should return the fid for an itunes url" do
      expect(UrlCommon.parse_fid_from_itunes_url("https://itunes.apple.com/us/app/imovie/id408981434?mt=12")).to eq "408981434"
    end

    it "should return nil when there is no fid" do
      expect(UrlCommon.parse_fid_from_itunes_url("https://itunes.apple.com/us/app/imovie/")).to be_nil
    end
  end
  
  describe ".parse_country_from_itunes_url" do
    it "should return the country for an itunes url" do
      expect(UrlCommon.parse_country_from_itunes_url("https://itunes.apple.com/us/app/imovie/id408981434?mt=12")).to eq "us"
    end

    it "should return us when there is no country" do
      expect(UrlCommon.parse_country_from_itunes_url("https://itunes.apple.com/app/imovie/")).to eq 'us'
    end

    it "should return the it when it (italy) is specified" do
      expect(UrlCommon.parse_country_from_itunes_url("https://itunes.apple.com/it/app/imovie/id408981434?mt=12")).to eq "it"
    end
  end
  
  describe ".get_base_domain" do
    it "should return the base domain for itunes.apple.com" do
      expect(UrlCommon.get_base_domain("https://itunes.apple.com/us/app/imovie/id408981434?mt=12")).to eq "itunes.apple.com"
    end

    it "should return the base domain for www.scripting.com" do
      expect(UrlCommon.get_base_domain("https://www.scripting.com/app/imovie/")).to eq 'scripting.com'
    end

    it "should return the base domain for scripting.com" do
      expect(UrlCommon.get_base_domain("https://scripting.com/it/app/imovie/id408981434?mt=12")).to eq "scripting.com"
    end

    it "should return the base domain for foo.scripting.coml" do
      expect(UrlCommon.get_base_domain("https://foo.scripting.com/it/app/imovie/id408981434?mt=12")).to eq "foo.scripting.com"
    end
  end
  
  describe ".join" do
    it "should join the url fragments without double slashes" do
      expect(UrlCommon.join("https://foo.scripting.com/", "stories")).to eq "https://foo.scripting.com/stories"
    end

    it "should join the url fragments without double slashes" do
      expect(UrlCommon.join("https://foo.scripting.com", "stories")).to eq "https://foo.scripting.com/stories"
    end
  end
  
  describe ".url_no_www" do
    it "should strip the www" do
      expect(UrlCommon.url_no_www("https://www.scripting.com/")).to eq "scripting.com/"
    end

    it "should strip the www" do
      expect(UrlCommon.url_no_www("https://scripting.com")).to eq "scripting.com"
    end
    
    it "should strip the www" do
      expect(UrlCommon.url_no_www("https://foo.scripting.com/stories")).to eq "foo.scripting.com/stories"
    end
    
  end
  
  describe ".agent" do
    it "should return an agent" do
      expect(UrlCommon.agent.class.to_s).to eq "Mechanize"
    end
  end
  
  describe ".strip_a_tag" do
    it "should strip the a tag" do
      expect(UrlCommon.strip_a_tag('<a href="https://www.keyingredient.com/recipes/12194051/egg-salad-best-ever-creamy/">')).to eq 'https://www.keyingredient.com/recipes/12194051/egg-salad-best-ever-creamy/'
    end
  end
  
  describe ".url_base" do
    it "should return the url base w/o the www" do
      expect(UrlCommon.url_base("https://www.udemy.com/the-build-a-saas-app-with-flask-course/")).to eq "udemy.com/the-build-a-saas-app-with-flask-course/"
    end
  end
  
  describe ".check_for_amazon_referrer" do
    it "should return true for a link that contains the specified referrer code" do
      url = "https://www.amazon.com/gp/product/B01DT4A2R4/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&tag=nickjanetakis-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01DT4A2R4&linkId=496be5e222b6291369c0a393c797c2c0"
      referrer_code = "nickjanetakis"
      expect(UrlCommon.check_for_amazon_referrer(url, referrer_code)).to be_truthy
    end

    it "should return false for a link that contains the specified referrer code" do
      url = "https://www.amazon.com/gp/product/B01DT4A2R4/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&tag=nickjanetakis-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01DT4A2R4&linkId=496be5e222b6291369c0a393c797c2c0"
      referrer_code = "nickjanetakis1"
      expect(UrlCommon.check_for_amazon_referrer(url, referrer_code)).to be_falsy
    end

    it "should return nil for a link that isn't amazon at all" do
      url = "https://www.boolean.com/gp/product/B01DT4A2R4/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&tag=nickjanetakis-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01DT4A2R4&linkId=496be5e222b6291369c0a393c797c2c0"
      referrer_code = "nickjanetakis1"
      expect(UrlCommon.check_for_amazon_referrer(url, referrer_code)).to be_nil
    end
  end


  # #pending "add some examples to (or delete) #{__FILE__}"

  # describe ".url_no_www" do
  #   it "should strip the www from a url" do
  #     UrlCommon.url_no_www("http://www.google.com").should == "google.com"
  #   end
  # end
  #
  describe ".has_own_domain?" do
    it "should return true for ma.tt" do
      expect(UrlCommon.has_own_domain?("http://ma.tt")).to be_truthy
    end

    it "should return true for www.ma.tt" do
      expect(UrlCommon.has_own_domain?("http://www.ma.tt")).to be_truthy
    end

    it "should return false for fuzzyblog.github.io" do
      expect(UrlCommon.has_own_domain?("http://fuzzyblog.github.io")).to be_falsey
    end

    it "should return false for cartazzi.wordpress.com" do
      expect(UrlCommon.has_own_domain?("http://cartazzi.wordpress.com")).to be_falsey
    end

    it "should return false for cartazzi.wordpress.com" do
      expect(UrlCommon.has_own_domain?("http://cartazzi.blogspot.com")).to be_falsey
    end

    it "should return true for tnl.net" do
      expect(UrlCommon.has_own_domain?("http://tnl.net")).to be_truthy
    end
  end
  
  describe ".fix_relative_url" do
    it "should NOT fix urls with http" do
      base_url = "https://www.udemy.com/the-build-a-saas-app-with-flask-course/"
      partial_url = "https://www.udemy.com/the-build-a-saas-app-with-flask-course/#instructor-16148498"
      expect(UrlCommon.fix_relative_url(base_url, partial_url)).to eq partial_url
      
    end
    
    it "should fix relative urls" do
      base_url = "https://www.udemy.com/the-build-a-saas-app-with-flask-course/"
      partial_url = "/the-build-a-saas-app-with-flask-course/#instructor-16148498"
      expect(UrlCommon.fix_relative_url(base_url, partial_url)).to eq "https://www.udemy.com/the-build-a-saas-app-with-flask-course/#instructor-16148498"
      
    end
  end
  
  describe ".validate_with_merge_fragment" do
    # 2.7.1 :002 > status, url = UrlCommon.validate_with_merge_fragment("nickjj/orats", "https://www.github.com/")
    # 2.7.1 :003 > status
    #  => true
    # 2.7.1 :004 > url
    #  => "https://www.github.com/nickjj/orats"
    it "should validate the url and merge the fragment" do
      status, url = UrlCommon.validate_with_merge_fragment("nickjj/orats", "https://www.github.com/")
      expect(status).to be_truthy
      expect(url).to eq "https://www.github.com/nickjj/orats"
    end
  end
  
#   describe ".possible_rssurls" do
#     # it "should return an array of possible rss urls based on an input url" do
#     #   possible_rssurls = UrlCommon.possible_rssurls("http://fuzzyblog.io")
#     #   possible_rssurls.
#     # end
#   end
#
#   describe ".parse_html_for_rssurl_from_head" do
#     it "should find the feed url for coding horror" do
#       blog_url = "https://blog.codinghorror.com/"
#       feed_url = "http://feeds.feedburner.com/codinghorror"
#       expect(UrlCommon.parse_html_for_rssurl_from_head(blog_url)).to eq feed_url
#     end
#
#     it "should find the feeds for holdingspace" do
#       blog = "https://holdingspacellc.wordpress.com/"
#       feed = "https://holdingspacellc.wordpress.com/feed/"
#       expect(UrlCommon.parse_html_for_rssurl_from_head(blog)).to eq feed
#     end
#
#     it 'should find the feeds for simon' do      expect(UrlCommon.parse_html_for_rssurl_from_head("http://simonwillison.net/")).to eq "http://simonwillison.net/atom/everything/"
#     end
#
#     it 'should find the feeds for simon' do      expect(UrlCommon.parse_html_for_rssurl_from_head("https://simonwillison.net/")).to eq "https://simonwillison.net/atom/everything/"
#     end
#   end
#
#   describe "select_best_feed" do
#   end
#
#   describe "discover_feed_url" do
#     it "should find the feeds for 500 hats" do
#       expect(UrlCommon.discover_feed_url("https://500hats.com/")).to eq "https://500hats.com/feed/"
#     end
#
#     it "should find the feeds for michael z williamzon" do
#       expect(UrlCommon.discover_feed_url("http://www.michaelzwilliamson.com/blog/")).to eq "http://www.michaelzwilliamson.com/blog/xml-rss2.php"
#     end
#
#     it "should find the feeds for Seanan" do
#       expect(UrlCommon.discover_feed_url("http://seananmcguire.com/blog/")).to eq "http://seananmcguire.com/blog/feed/"
#
#     end
#
#     it "should find the feeds for Seanan's blog" do
#             expect(UrlCommon.discover_feed_url("http://seananmcguire.com/")).to eq "http://seananmcguire.com/blog/feed/"
#     end
#
#     it 'should find the feeds for simon' do
#       expect(UrlCommon.discover_feed_url("http://simonwillison.net/")).to eq "https://simonwillison.net/atom/everything/"
#     end
#
#     it "should find the feeds for holdingspace" do
#       blog = "https://holdingspacellc.wordpress.com/"
#       feed = "https://holdingspacellc.wordpress.com/feed/"
#       expect(UrlCommon.discover_feed_url(blog)).to eq feed
#     end
#
#     it "should find the feeds for lisa meece" do
#       blog = "https://www.lisameece.com/blog/"
#       feed = "https://www.lisameece.com/blog/blog-feed.xml"
#       expect(UrlCommon.discover_feed_url(blog)).to eq feed
#     end
#
#     it "should find the feeds for coding horror" do
#       blog = "https://blog.codinghorror.com/"
#       feed = "http://feeds.feedburner.com/codinghorror"
#       expect(UrlCommon.discover_feed_url(blog)).to eq feed
#     end
#
# =begin
#     it "should find the feeds for coding horror" do
#       blog = ""
#       feed = ""
#       expect(UrlCommon.discover_feed_url(blog)).to eq feed
#     end
# =end
#   end
end

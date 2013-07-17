require 'open-uri'
require 'mechanize'
require 'json'

class Staplegun
  def initialize(options={})
    unless options[:email] || options[:password]
      raise ArgumentError, "You must initialize with options[:email] and options[:password]."
    end

    @options = options

    @agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.follow_meta_refresh = true
    }

  end

  def self.login!(options={})
    instance = new(options)
    instance.authenticate
  end

  def self.login(options={})
    begin
      self.login!(options)
    rescue
      false
    end
  end

  def authenticate
    @agent.get('https://pinterest.com/login')
    @csrf_token = @agent.cookie_jar.jar['pinterest.com']['/']['csrftoken'].value

    data = {
      :options => {
        :username_or_email => @options[:email],
        :password => @options[:password]
      },
      :context => {
        :app_version => @options[:app_version] || "783f800"
      }
    }

    params = {
      'data' => JSON.generate(data),
      'source_url' => "/login/",
      'module_path' => "App()>LoginPage()>Login()>Button(class_name=primary, text=Log in, type=submit, tagName=button, size=large)"
    }

    @agent.post "https://pinterest.com/resource/UserSessionResource/create/",
      params,
      headers('Referer' => "https://pinterest.com/login/")

    return self
  end

  def pin!(pin)
    @agent.get generate_pin_url(pin, :domain => true)

    data = {
      :options => {
        :board_id => pin[:board_id],
        :link => pin[:link],
        :share_twitter => false,
        :image_url => pin[:image_url],
        :method => "button",
        :is_video => nil
      },
      :context => {
        :app_version => "783f800"
      }
    }

    data[:options][:description] = pin[:description] if pin[:description]

    params = {
      :source_url => generate_pin_url(pin),
      :data => JSON.generate(data),
      :module_path => "App()>PinBookmarklet()>PinCreate()>PinForm()>Button(class_name=repinSmall pinIt, text=Pin it, disabled=false, has_icon=true, tagName=button, show_text=false, type=submit, color=primary)"
    }

    @agent.post 'http://pinterest.com/resource/PinResource/create/',
      params,
      headers('Referer' => generate_pin_url(pin, :domain => true))

    return self
  end

  def pin(pin)
    begin
      pin!(pin)
    rescue
      false
    end
  end

  private

  def generate_pin_url(pin, options={})
    link = URI::encode pin[:link]
    image_url = URI::encode pin[:image_url]

    url = "/pin/create/button/?url=#{link}&media=#{image_url}"
    url = "http://pinterest.com" + url if options[:domain]

    if pin[:description]
      description = URI::encode pin[:description]
      url.concat"&description=#{description}"
    end

    return url
  end

  def headers(options={})
    default = {
      'Accept' => 'application/json, text/javascript, */*; q=0.01',
      'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
      'Accept-Encoding' => 'gzip,deflate,sdch',
      'Accept-Language' => 'en-US,en;q=0.8',
      'Cache-Control' => 'no-cache',
      'Connection' => 'keep-alive',
      'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
      'Host' => 'pinterest.com',
      'Origin' => 'http://pinterest.com',
      'Pragma' => 'no-cache',
      'Referer' => 'https://pinterest.com/',
      'X-CSRFToken' => @csrf_token,
      'X-NEW-APP' => '1',
      'X-Requested-With' => 'XMLHttpRequest'
    }

    default.merge! options
  end

end

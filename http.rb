require "net/https"

class MyHttp
  def self.get(url, header, params = {})
    uri = URI(url)
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.hostname, uri.port)
    # https.proxy_from_env = true
    if uri.port == 443
      http.use_ssl = true
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    res = http.start do
      req = Net::HTTP::Get.new(uri, header)
      http.request(req)
    end

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      res.body
    else
      # レスポンスが 2xx(成功)でなかった場合に、対応する例外を発生させます。
      res.value
    end
  end

  def self.post(url, header, params)
    uri = URI(url)

    http = Net::HTTP.new(uri.hostname, uri.port)
    # https.proxy_from_env = true
    if uri.port == 443
      http.use_ssl = true
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    res = http.start do
      req = Net::HTTP::Post.new(uri, header)
      req.set_form_data(params)
      http.request(req)
    end

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      res.body
    else
      # レスポンスが 2xx(成功)でなかった場合に、対応する例外を発生させます。
      res.value
    end
  end
end

require 'base64'
require 'net/http'
require 'openssl'
require 'time'
require 'amazon_product/version'

# A very simple client for the Amazon Product Advertising API.
class AmazonProduct
  ENDPOINT = URI.parse('https://ecs.amazonaws.co.uk/onca/xml')
  SERVICE = 'AWSECommerceService'
  API_VERSION = '2011-08-01'
  AMPERSAND = '&'
  COMMA = ','
  PERCENT = '%'
  HTTPS = 'https'
  USER_AGENT = "amazon_product #{VERSION}"
  HEADERS = {'User-Agent' => USER_AGENT, 'Accept' => 'application/xml'}
  DIGEST = OpenSSL::Digest::SHA256.new
  ENCODE = /([^a-zA-Z0-9_.~-]+)/

  attr_reader :connection

  # @param access_key_id [String] your Amazon access key ID
  # @param secret_access_key [String] your Amazon secret access key
  # @param associate_tag [String] your Amazon associate tag
  def initialize(access_key_id, secret_access_key, associate_tag)
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
    @associate_tag = associate_tag
    @connection = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
    @default_params = {
      'Service' => SERVICE,
      'Version' => API_VERSION,
      'AWSAccessKeyId' => @access_key_id,
      'AssociateTag' => @associate_tag
    }

    if ENDPOINT.scheme == HTTPS
      @connection.use_ssl = true
    end
  end

  # @param operation [String] the operation name
  # @param response_groups [Array<String>] a list of response groups
  # @param operation_params [Hash] all other parameters required by the operation
  # @return [Net::HTTPResponse]
  def get(operation, response_groups, operation_params = {})
    base_params = {
      'Operation' => operation,
      'ResponseGroup' => response_groups.join(COMMA),
      'Timestamp' => Time.now.xmlschema
    }

    unsigned_params = operation_params.merge(@default_params.merge(base_params))

    signed_params = unsigned_params.merge({'Signature' => signature(unsigned_params)})

    request_uri = ENDPOINT.dup
    request_uri.query = query_string(signed_params)

    @connection.request(Net::HTTP::Get.new(request_uri.to_s, HEADERS))
  end

  private

  # @param string [String] the string to URL encode
  # @return [String] the URL encoded string
  def url_encode(string)
    string.gsub(ENCODE) do
      PERCENT + $1.unpack('H2' * $1.bytesize).join(PERCENT).upcase
    end
  end

  # @param params [Hash]
  # @return [String]
  def query_string(params)
    params.map do |key, value|
      "%s=%s" % [key, url_encode(value)]
    end.sort.join(AMPERSAND)
  end

  # @param params [Hash]
  # @return [String] the request signature
  def signature(params)
    signable = "GET\n%s\n%s\n%s" % [ENDPOINT.host, ENDPOINT.path, query_string(params)]
    hmac = OpenSSL::HMAC.digest(DIGEST, @secret_access_key, signable)
    Base64.encode64(hmac).chomp
  end
end
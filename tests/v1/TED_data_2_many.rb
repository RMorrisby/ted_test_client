$LOAD_PATH.unshift("#{File.expand_path(File.dirname(__FILE__))}/../../lib")

require 'ted_client_test_case'

class TED_DATA_2_MANY < Test::Unit::TestCase
  include TedClientTestCase

  def setup
    super
  end  
  
      ########################################################################
      # PURPOSE :
      #   Send several test results to TED
      #
      # PRECONDITIONS :
      #   None
      ########################################################################

# TODO take in result-count from commandline

  def test_TED_data_2_many

    increment_version_number
    version = read_version_number

    $WRITE_RESULTS = false # deliberately suppress the teardown's writing of results

    # We will cheat here & send directly to TED
    
    count = 4 # TODO read count from commandline

    count.times do |i|
      ted_result = TEDResult.new
      ted_result.test_run_identifier = version
      ted_result.name = self.to_s.split("(")[0] + "_" + (i + 1).to_s
      ted_result.category = "Test client"
      ted_result.status = "PASSED" # TODO randomise this?
      ted_result.timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      ted_result.message = ""

      puts ted_result.to_s

      url = TedClientConfig::SERVER[:ted_url_send_in_result]
      puts "Now sending POST to #{url}"
      # resp = RestClient.post(url, ted_result.to_json)
      
      # resource = RestClient::Resource.new(
      #     url,
      #     verify_ssl: false
      #   )
        
      #   resp = resource.post(ted_result.to_json)

      
        resp = RestClient::Request.execute(method: :post, url: url,
          payload: ted_result.to_json,
          verify_ssl: false)

      puts resp.code
      puts resp.body
    end # end count
  end



end

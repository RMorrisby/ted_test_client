$LOAD_PATH.unshift("#{File.expand_path(File.dirname(__FILE__))}/../../lib")

require 'ted_client_test_case'

class TED_DATA_0_SUITE_AND_TEST_SETUP < Test::Unit::TestCase
  include TedClientTestCase

  def setup
    super
  end  
  
      ########################################################################
      # PURPOSE :
      #   Create the default project in TED and register the default set of tests
      #
      # PRECONDITIONS :
      #   None
      ########################################################################


  def test_TED_data_0_suite_and_test_setup

    $WRITE_RESULTS = false # deliberately suppress the teardown's writing of results

    # We will send directly to TED

    # Send the suite first
    ted_suite = TEDSuite.new
    ted_suite.name = TedClientConfig::DEFAULT_SUITE_NAME
    ted_suite.description = "Test suite for testing TED with"
    ted_suite.owner = TedClientConfig::DEFAULT_OWNER
    ted_suite.notes = ""

    puts ted_suite.to_s

    url = TedClientConfig::SERVER[:ted_url_send_in_suite]

    # Try to get the suite from TED; don't send the suite in if TED already knows about it
    query_url = url + "?suite=" + ted_suite.name
    puts "Now sending GET to #{query_url}"

    resp = RestClient::Request.execute(method: :get, url: query_url,
      verify_ssl: false)
    puts resp.code
    puts resp.body

    assert_equal(200, resp.code, "GET to fetch suite did not return a 200 code")

    if resp.body == "Suite '#{ted_suite.name}' is not registered in TED"
      puts "TED does not know about this suite; will now send it to TED"

      puts "Now sending POST to #{url}"
      resp = RestClient::Request.execute(method: :post, url: url,
        payload: ted_suite.to_json,
        verify_ssl: false)

      puts resp.code
      puts resp.body

      assert_equal(201, resp.code, "POST to create suite did not return a 201 code")

      else 
        received = JSON.parse(resp.body)
        expected = JSON.parse(ted_suite.to_s)

        assert_equal(expected, received, "GET to fetch suite did not return the expected values")
    end

    ##################################################
    ##################################################
    ##################################################
    ##################################################

    # Now register a test

    ted_test = TEDTest.new
    ted_test.name = "TED_data_1"
    ted_test.dir = "v1"
    ted_test.priority = 3
    ted_test.categories = %w{smoke basic}.join("|")
    ted_test.description = "TED client test 1"
    ted_test.notes = ""
    ted_test.owner = TedClientConfig::DEFAULT_OWNER

    puts ted_test.to_s

    url = TedClientConfig::SERVER[:ted_url_send_in_test]

    # Try to get the test from TED; don't send the test in if TED already knows about it
    query_url = url + "?test=" + ted_test.name
    puts "Now sending GET to #{query_url}"

    resp = RestClient::Request.execute(method: :get, url: query_url,
      verify_ssl: false)
    puts resp.code
    puts resp.body

    assert_equal(200, resp.code, "GET to fetch test did not return a 200 code")

    if resp.body == "Test '#{ted_test.name}' is not registered in TED"
      puts "TED does not know about this test; will now send it to TED"

      puts "Now sending POST to #{url}"
      resp = RestClient::Request.execute(method: :post, url: url,
        payload: ted_test.to_json,
        verify_ssl: false)

      puts resp.code
      puts resp.body

      assert_equal(201, resp.code, "POST to create test did not return a 201 code")

      else 
        received = JSON.parse(resp.body)
        expected = JSON.parse(ted_test.to_s)

        assert_equal(expected, received, "GET to fetch test did not return the expected values")
    end

  end



end

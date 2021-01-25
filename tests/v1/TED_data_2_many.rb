$LOAD_PATH.unshift("#{File.expand_path(File.dirname(__FILE__))}/../../lib")

require 'ted_client_test_case'

class TED_DATA_2_MANY < Test::Unit::TestCase
  include TedClientTestCase

  @@priority = 2
  @@categories = %w{basic}
  @@description = "TED Client test 2 - multiple test results"
  @@owner = "RSM"
  @@test_file_dir = File.dirname(__FILE__).split("/")[-1]
  
  def setup
    increment_version_number # TODO tests should not call this - the suite-setup should (and only once per suite-run)
    load_version_number
    # super # Do not call super - we do not want to register this 'test' with TED
    @test_start_time = Time.now
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

    $WRITE_RESULTS = false # deliberately suppress the teardown's writing of results

    # We will cheat here & send directly to TED
    
    # count = 4 # TODO read count from commandline

    # count.times do |i|
    #   send_to_ted(i)      
    # end # end count

    statuses = %w{ PASSED FAILED }
    @expected_reruns = []

    suffix = "always_pass"
    status = "PASSED"
    send_to_ted(suffix, status)

    suffix = "always_fail"
    status = "FAILED"
    send_to_ted(suffix, status)

    suffix = "pass_or_fail"
    status = statuses.random
    send_to_ted(suffix, status)

    suffix = "maybe_not_run"
    # 50% of the time, don't run this test
    status = ((rand(10) % 2 == 0) ? statuses.random : nil)
    puts "Status was decided to be nil; will not send to TED" if status == nil
    send_to_ted(suffix, status)


    # Now get the list of reruns
    @expected_reruns.uniq!
    puts "Expected reruns : " + @expected_reruns.join(", ")

    url = TedClientConfig::SERVER[:ted_url_reruns]
    url += "?testrun=#{@@version}"
    puts "Now sending GET to #{url}"
    
    resp = RestClient::Request.execute(method: :get, url: url,
        verify_ssl: false)

    puts resp.code
    puts resp.body

      reruns = JSON.parse(resp.body)
      assert_equal(@expected_reruns.size, reruns.size, "Wrong number of reruns returned from TED")

      found_reruns = []
      reruns.each do |hash|
        found_reruns << hash["TestName"]
      end

      found_reruns.uniq!
      assert_equal(@expected_reruns.sort, found_reruns.sort, "Wrong reruns returned from TED")

    @test_end_time = Time.now
  end

  def send_to_ted(suffix, status)
    # If the status is nil, we want to not send it to TED
    puts "#{suffix} :: #{status}"
    return unless status
    
    @test_name = self.to_s.split("(")[0] + "_" + suffix
    ted_test = TEDTest.new
    ted_test.name = @test_name
    ted_test.dir = @@test_file_dir
    ted_test.priority = @@priority
    ted_test.categories = @@categories.join("|")
    ted_test.description = @@description
    ted_test.notes = @@notes
    ted_test.owner = @@owner
    
    register_test_with_ted


    ted_result = TEDResult.new
    ted_result.suite = TedClientConfig::DEFAULT_SUITE_NAME
    ted_result.name = self.to_s.split("(")[0] + "_" + suffix
    ted_result.test_run = @@version
    ted_result.status = status
    ted_result.start_timestamp = (Time.now - 5).strftime("%Y-%m-%d %H:%M:%S")
    ted_result.end_timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    ted_result.ran_by = TedClientConfig::DEFAULT_OWNER
    # ted_result.message = ""

    puts ted_result.to_s

    @expected_reruns << ted_result.name if ted_result.status != "PASSED"

    url = TedClientConfig::SERVER[:ted_url_send_in_result]
    puts "Now sending POST to #{url}"
    
      resp = RestClient::Request.execute(method: :post, url: url,
        payload: ted_result.to_json,
        verify_ssl: false)

    puts resp.code
    puts resp.body
  end
end

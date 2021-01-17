
# This file defines a module to be included in all test cases for the testing of TED CLIENT.
# This module contains a general setup and teardown method that each test should run.
# If tests wish to perform their own specific seup and/or teardown routines, they 
# should implement their own methods and call super within them to trigger these common
# setup/teardown methods at the right time.

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/.."))

gem 'test-unit'
require 'test/unit'
require 'tmpdir'
require 'time'
require 'fileutils'
require 'timeout'
require 'more_ruby'
require 'rest-client'
# require 'watir'


# Config
require 'config/ted_client_config.rb'

# Helpers
# require 'framework/ted_client.rb'
require 'framework/ted_suite.rb'
require 'framework/ted_test.rb'
require 'framework/ted_result.rb'



STDOUT.sync = true

module TedClientTestCase

    attr_accessor :browser_has_been_opened

    # optional field
    # If the cause of a test's failure is already likely to be known, the contents of this variable 
    # will automatically be added to the test result's Notes field, to help with reporting.
    # If there are multiple tests in a file, this variable needs to be set within each test 
    # method (if they have any relevent failure notes).
    attr_accessor :failure_notes

    # E.g. calling homepage.displayed? from a test script :
    # Test cannot see homepage so its call is routed through method_missing
    # If method_missing returns an instance of the class, .displayed? can be called on it (seamlessly)
    # At present this will happen for every call to a page from a test script
    # def method_missing(name, *args, &block)
    #     #puts "TedClientTestCase method_missing called; name = #{name.inspect}; #{name.class}"
 
    #     case name.to_s
    #     when /^browser$/
    #         browser
    #     when /^tedclient/i
    #         TEDCLIENTPages.find(name.to_s) # return the page so that the test can use it
    #     else
    #         super
    #     end
    # end

    # if $WRITE_RESULTS # supplied from invokation
    # if $*.include?("WRITE_RESULTS")
    #     WRITE_RESULTS = true
    # else
    #     WRITE_RESULTS = false
    # end

    # Connect to TED CLIENT and reinitialise the context, etc.
    # def tedclient_login(url = TedClientConfig::SERVER[:ted_client_url])
    #     browser = @help.new_browser_at_url(url)
    #     load_pages(browser)
    # end

    # def load_pages(browser)
    #     TEDCLIENTPages.make_pages(browser) # cannot have pages without a browser object
    #     $browsers << browser
    #     @browser_has_been_opened = true
    # end

    # # Close the current browser
    # def close_browser
    #     browser.close
    # end

    # def close(browser)
    #     if browser.exists? && ((TedClientConfig::CLOSE_BROWSER_AFTER_TEST && passed?) || TedClientConfig::FORCE_CLOSE_BROWSER_AFTER_TEST)
    #         browser.close
    #         $browsers.delete_at($current_browser_position - 1) # array indexing
    #         browser = $browsers[-1] # set browser to the last one that is still in the array
    #     end
    # end

    # def close_all_browsers
    #     if (TedClientConfig::CLOSE_BROWSER_AFTER_TEST && passed?) || TedClientConfig::FORCE_CLOSE_BROWSER_AFTER_TEST
    #         until $browsers.empty?
    #             browser = $browsers.shift
    #             browser.close
    #         end
    #     end
    # end

    @@version = nil
    @@browser = nil

    def browser
        @@browser
    end

    def browser=(b)
        @@browser = b
    end
    alias set_browser browser= # note : calls of "browser = " do not work, calls of "browser=" do

    # Increments the value in test_run_id_increment.txt
    def increment_version_number
        lines = get_version_number_file_lines
        v = lines[0]

        v =~ /^v(\d+).(\d+).(\d+)$/
        major = $1.to_i
        minor = $2.to_i
        patch = $3.to_i

        patch += 1
        if patch > 15
            minor += 1 
            patch = 0
        end
        if minor > 15
            major += 1 
            minor = 0
        end
        
        new_v = "v#{major}.#{minor}.#{patch}"
        File.open("test_run_id_increment.txt", "w") do |f|
            f.puts new_v
        end
        puts "Incremented version number to #{new_v}"
    end

    # Initialise the class variables used for the TEDTest object
    @@priority = nil
    @@categories = []
    @@description = nil
    @@owner = nil
    @@notes = nil
    @@test_file_dir = nil
    

    # Sends the test's result to TED
    def register_test_with_ted

        ted_test = TEDTest.new
        ted_test.name = @test_name
        ted_test.dir = @@test_file_dir
        ted_test.priority = @@priority
        ted_test.categories = @@categories.join("|")
        ted_test.description = @@description
        ted_test.notes = @@notes
        ted_test.owner = @@owner
    
        puts ted_test.to_s
    
        url = TedClientConfig::SERVER[:ted_url_send_in_test]
    
        # Try to get the test from TED; don't send the test in if TED already knows about it
        query_url = url + "?test=" + ted_test.name
        puts "Now sending GET to #{query_url}"
    
        begin
            resp = RestClient::Request.execute(method: :get, url: query_url,
            verify_ssl: false)
            code = resp.code
            body = resp.body
        rescue => e
            code = e.response.code
            body = e.response.body
        end
        puts code
        puts body
        assert_equal(200, resp.code, "GET to fetch test did not return a 200 code")
    
        # If the test is not registered, register it
        if resp.body == "Test '#{ted_test.name}' is not registered in TED"
            puts "TED does not know about this test; will now send it to TED"
        
            puts "Now sending POST to #{url}"
            begin
                resp = RestClient::Request.execute(method: :post, url: url,
                    payload: ted_test.to_json,
                    verify_ssl: false)
                code = resp.code
                body = resp.body
            rescue => e
                code = e.response.code
                body = e.response.body
            end
            puts code
            puts body
        
            unless code == 201
                puts "TED rejected the test registration with code #{code}. This test was sent :"
                puts ted_test
            end
    
        else 
            received = JSON.parse(resp.body)
            expected = JSON.parse(ted_test.to_s)
    
            # Our object ('expected') shouldn't have the Known Issue fields. But TED should return an object with them
            # Take the values for those fields, so that the assertion doesn't trip over them
            expected["IsKnownIssue"] ||= received["IsKnownIssue"]
            expected["KnownIssueDescription"] ||= received["KnownIssueDescription"]
            expected["Notes"] ||= "" # TED currently returns "" instead of nil
            assert_equal(expected, received, "GET to fetch test did not return the expected values. Something has gone wrong.")
        end

        
        # ##################################

        # puts ted_test.to_s

        # url = TedClientConfig::SERVER[:ted_url_send_in_test]
        # puts "Now sending POST to #{url}"

        # begin
        #     resp = RestClient::Request.execute(method: :post, url: url,
        #         payload: ted_test.to_json,
        #         verify_ssl: false)
        #     code = resp.code
        #     body = resp.body
        # rescue => e
        #     code = e.response.code
        #     body = e.response.body
        # end

        # puts code
        # puts body

        # unless code == 201
        #     puts "TED rejected the test registration with code #{code}. This test was sent :"
        #     puts ted_test
        # end
    end

    # Sends the test's result to TED
    def send_result_to_ted(test_name, status, test_start_time, test_end_time, notes)

        ted_result = TEDResult.new
        ted_result.suite = TedClientConfig::DEFAULT_SUITE_NAME
        ted_result.name = test_name
        ted_result.test_run = @@version # @@version is set in setup
        ted_result.status = status
        ted_result.start_timestamp = test_start_time
        ted_result.end_timestamp = test_end_time
        ted_result.ran_by = TedClientConfig::DEFAULT_OWNER
        ted_result.message = notes unless notes.empty?

        puts ted_result.to_s

        url = TedClientConfig::SERVER[:ted_url_send_in_result]
        puts "Now sending POST to #{url}"

        begin
            resp = RestClient::Request.execute(method: :post, url: url,
                payload: ted_result.to_json,
                verify_ssl: false)
            code = resp.code
            body = resp.body
        rescue => e
            code = e.response.code
            body = e.response.body
        end

        puts code
        puts body

        unless code == 201
            puts "TED rejected the test result with code #{code}. This result was sent :"
            puts ted_result
        end
    end

    def get_version_number_file_lines
        path = File.expand_path(File.dirname(__FILE__)) + "/../" + TedClientConfig::TEST_RUN_ID_FILE
        lines = File.readlines(path)
        lines
    end

    # Reads in test_run_id_increment.txt - the tests will use this value as the test run ID
    def load_version_number
        unless @@version
            lines = get_version_number_file_lines
            v = lines[0]
            puts "Version number in file : " + v
            @@version = v
        end
    end



    # Ensure that every test (that wants one) has a browser that is already logged in to the system
    def setup

        # @help = TEDCLIENTHelper.new

        # Watir.always_locate = true # default is true; setting to false speeds up Watir to a degree

        # Get start time for later output in results
        @test_start_time = Time.now

        # Get the directory that the specific test lives in, so that it can be included in the results file
        @test_file_dir = @test_file.split(File::SEPARATOR)[-2] if @test_file

        @test_name = self.to_s.split("(")[0]

        # Select default certificate if none is configured
        @certificate ||= :regular

        # @timeout = TedClientConfig::CERTIFICATE_POPUP_TIMEOUT

        # Open the browser & ensure page contenxt and helper are available
        $browsers = [] # global array containing all browser objects
        # $current_browser_position = nil # global variable to track the position in $browsers of the active browser # TODO used?
        # When that browser is closed, we can ensure that the corresponding browser object is removed from the array
        # if @initialBrowser == :tedclient
        #     tedclient_login
        # elsif (@initialBrowser == :none || @initialBrowser == nil)
        #     browser = nil
        # end

        load_version_number

        register_test_with_ted
    end # end setup

    # Close all browsers and write the result of the test to the results CSV
    def teardown

        begin
            # Get end time
            @test_end_time = Time.now
            elapsed_time = (@test_end_time - @test_start_time).to_s
            elapsed_time_in_minutes = (elapsed_time.to_i/60.0).to_s

            test_name = self.to_s.split("(")[0] # self.to_s gives output like test_ABC5_01(TC_ABC5_01)

            puts "Test has now finished; #{test_name} : #{passed?}"

            if $WRITE_RESULTS
                raise "TEST_ENV '#{$TEST_ENV}' was not recognised" if TedClientConfig::SERVER == nil

                puts "Will now write results to #{TedClientConfig::RESULTS_BASE_DIR}"

                notes = ""
                success_text = passed? ? TedClientConfig::PASSED : TedClientConfig::FAILED
                ted_status = passed? ? TEDResult::PASSED : TEDResult::FAILED

                unless passed?
                    begin
                        if TedClientConfig::MAKE_ERROR_SCREENSHOTS
                            puts "Now taking error screenshots"
                            dir_2 = TedClientConfig::ERROR_SCREENSHOT_LOCATION
                            Dir.mkdir(dir_2) unless File.exists?(dir_2)
                            $browsers.each do |browser|
                                browser.screenshot.save(TedClientConfig::ERROR_SCREENSHOT_LOCATION + "/#{test_name}_Time_#{@test_end_time.strftime("%H-%M-%S")}_Browser_#{$browsers.index(browser)}.png")
                            end
                        end
                    rescue
                        puts "Failed to make screenshot"
                    end
                    notes = @failure_notes
                    puts "Notes : #{notes}"
                end # end unless passed?

                
                # Write to the results file
                begin
                    File.open(TedClientConfig::RESULTS_CSV, "a") do |f|
                        row = [@test_file_dir, test_name, success_text, @test_start_time.strftime("%Y-%m-%d %H:%M:%S"), @test_end_time.strftime("%Y-%m-%d %H:%M:%S"), elapsed_time, elapsed_time_in_minutes, notes]
                        f.puts row.join(",")
                        puts "Result for test #{test_name} written"
                    end
                rescue
                    puts "Had to rescue from writing results to file #{TedClientConfig::RESULTS_CSV}"
                end

                send_result_to_ted(test_name, ted_status, @test_start_time.gmtime, @test_end_time.gmtime, notes)
            end # end if $WRITE_RESULTS
            
            # close_all_browsers


        rescue Timeout::Error => t_error
            puts "Timeout::Error :"
            puts t_error
            puts "Backtrace :"
            puts t_error.backtrace
        rescue Exception => error
            puts "Error :"
            puts error
            puts "Backtrace :"
            puts error.backtrace
        end # end begin
    end



end



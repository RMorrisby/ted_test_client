$LOAD_PATH.unshift("#{File.expand_path(File.dirname(__FILE__))}/../../lib")

require 'ted_client_test_case'

class TED_DATA_1 < Test::Unit::TestCase
  include TedClientTestCase

  # Define the test's attributes
  # Keep these outside setup - if the test file contains multiple tests, each one will need to set these variables appropriately
  @@priority = 2
  @@categories = %w{smoke basic}
  @@description = "TED Client test 1 - basic +ve test"
  @@owner = "RSM"
  @@test_file_dir = File.dirname(__FILE__).split("/")[-1]
  

  def setup
    increment_version_number # TODO tests should not call this - the suite-setup should (and only once per suite-run)
    super
  end  
  
      ########################################################################
      # PURPOSE :
      #   Send some test results to TED
      #
      # PRECONDITIONS :
      #   None
      ########################################################################


  # def test_TED_data_1_a  
  #   #puts $TEST_ENV
  #   assert(false, "Test should always fail")

  # end


  def test_TED_data_1_b

    assert(true, "Test should always pass")

  end

end

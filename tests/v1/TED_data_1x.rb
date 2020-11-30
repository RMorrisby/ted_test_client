$LOAD_PATH.unshift("#{File.expand_path(File.dirname(__FILE__))}/../../lib")

require 'ted_client_test_case'

class TED_DATA_1 < Test::Unit::TestCase
  include TedClientTestCase

  def setup
    super
  end  
  
      ########################################################################
      # PURPOSE :
      #   Send some test results to TED
      #
      # PRECONDITIONS :
      #   None
      ########################################################################


  def test_TED_data_1_a  

    assert(false, "Test should always fail")

  end


  def test_TED_data_1_b

    assert(true, "Test should always pass")

  end

end

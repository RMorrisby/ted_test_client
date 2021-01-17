
# This class holds parameters that may frequently change between test runs, e.g the test environment
module RuntimeConstants

    if $TEST_ENV != nil # can override on command-line
        $TEST_ENV = $TEST_ENV.to_sym # if set on command-line, this ensures it is a symbol
    else
        $TEST_ENV = :local
    end
    
    $WRITE_RESULTS ||= true # can override on command-line

    CLOSE_BROWSER_AFTER_TEST = true # close the browser if the test passed?
    FORCE_CLOSE_BROWSER_AFTER_TEST = false # always close the browser?

    MAKE_ERROR_SCREENSHOTS = false
    ERROR_SCREENSHOT_LOCATION = "screenshots"

    WRITE_CI_REPORTS = false

    BROWSER = :chrome

    RESULTS_CSV = "results.csv"
    RESULTS_BASE_DIR = "."

    TEST_RUN_ID_FILE = "test_run_id_increment.txt"

end


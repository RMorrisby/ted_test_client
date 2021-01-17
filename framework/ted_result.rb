require 'json'

# Class representing a TED test result that is sent to TED
# This requires TED to already know about the suite and the test (by sending a TEDSuite and TEDTest object)
class TEDResult

    attr_accessor :suite
    attr_accessor :name
    attr_accessor :test_run # ID for the whole test run, e.g. "v0.1.2 run 3"
    attr_accessor :status # enum # PASSED, FAILED, NOT_RUN, SHOULD_HAVE_RUN, KNOWN_ISSUE, INTERMITTENT
    attr_accessor :start_timestamp
    attr_accessor :end_timestamp
    attr_accessor :ran_by
    # Optional fields
    attr_accessor :message


    # Valid statuses
    PASSED = "PASSED"
    FAILED = "FAILED"
    NOT_RUN = "NOT_RUN" # used by TED; clients should not send this status
    SHOULD_HAVE_RUN = "SHOULD_HAVE_RUN" # used by TED; clients should not send this status
    KNOWN_ISSUE = "KNOWN_ISSUE" # used by TED; clients should not send this status
    INTERMITTENT = "INTERMITTENT" # used by TED; clients should not send this status

    def to_json
        h = {}
        h[:SuiteName] = @suite
        h[:TestName] = @name
        h[:TestRunIdentifier] = @test_run
        h[:Status] = @status
        h[:StartTimestamp] = @start_timestamp
        h[:EndTimestamp] = @end_timestamp
        h[:RanBy] = @ran_by
        h[:Message] = @message if @message != nil

        JSON.pretty_generate(h)
    end

    alias :to_s :to_json

end
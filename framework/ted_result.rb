require 'json'

# Class representing a TED test result that is sent to TED
class TEDResult

    attr_accessor :name
    attr_accessor :category
    attr_accessor :status # enum # PASSED, FAILED, NOT_RUN, SHOULD_HAVE_RUN, KNOWN_ISSUE, INTERMITTENT
    attr_accessor :timestamp
    # Optional fields
    attr_accessor :message
    attr_accessor :test_run_identifier # ID for the whole test run, e.g. "v0.1.2 run 3"

    # Valid statuses
    PASSED = "PASSED"
    FAILED = "FAILED"
    NOT_RUN = "NOT_RUN" # used by TED; clients should not send this status
    SHOULD_HAVE_RUN = "SHOULD_HAVE_RUN" # used by TED; clients should not send this status
    KNOWN_ISSUE = "KNOWN_ISSUE" # used by TED; clients should not send this status
    INTERMITTENT = "INTERMITTENT" # used by TED; clients should not send this status



    def to_json
        h = {}
        h[:name] = @name
        h[:category] = @category
        h[:status] = @status
        h[:timestamp] = @timestamp
        h[:message] = @message if @message != nil
        h[:test_run_identifier] = @test_run_identifier if @test_run_identifier != nil

        JSON.pretty_generate(h)
    end

    alias :to_s :to_json

end
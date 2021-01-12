# Holds system configuration parameters

require_relative 'runtime_constants.rb'

class TedClientConfig
    include RuntimeConstants
    
    CERTIFICATE_DIR = "certs"
    CERTIFICATE_POPUP_TIMEOUT = 15

    API_VERSION = "latest"

    SERVERS = {
        :local => {:ted_url_send_in_result => "http://localhost:8080/result"},
        :test_1 => {:ted_url_send_in_result => "http://arcane-ravine-69473.herokuapp.com/result"},
    }

    # SERVERS = {
    #     :local => {:ted_url_send_in_result => "https://localhost:8080/result"},
    #     :test_1 => {:ted_url_send_in_result => "https://arcane-ravine-69473.herokuapp.com/result"},
    # }
    SERVER = SERVERS[$TEST_ENV]


    PASSED = "Passed"
    FAILED = "Failed"

    DISALLOWED_FIELD_NAMES = ["name"]

    ALL_USER_ROLES = ["all"]
end

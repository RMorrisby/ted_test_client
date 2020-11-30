# Holds system configuration parameters

require_relative 'runtime_constants.rb'

class TedClientConfig
    include RuntimeConstants
    
    CERTIFICATE_DIR = "certs"
    CERTIFICATE_POPUP_TIMEOUT = 15

    API_VERSION = "latest"

    SERVERS = {
        :local => {:ted_client_url => "https://localhost:8080"},
        :test_1 => {:ted_client_url => "https://"},
    }

    SERVER = SERVERS[$TEST_ENV]


    PASSED = "Passed"
    FAILED = "Failed"

    DISALLOWED_FIELD_NAMES = ["name"]

    ALL_USER_ROLES = ["all"]
end

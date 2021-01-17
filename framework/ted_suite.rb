require 'json'

# Class representing a TED test suite object
class TEDSuite

    attr_accessor :name
    attr_accessor :description
    attr_accessor :owner
    attr_accessor :notes # Optional

    def to_json
        h = {}
        h[:Name] = @name
        h[:Description] = @description
        h[:Owner] = @owner
        h[:Notes] = @notes  if @notes != nil

        JSON.pretty_generate(h)
    end

    alias :to_s :to_json

end
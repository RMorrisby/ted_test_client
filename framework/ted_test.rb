require 'json'

# Class representing a TED test object
class TEDTest
    # (name, dir, priority, categories, description, notes, owner, is_known_issue, known_issue_description) VALUES "


    attr_accessor :name
    attr_accessor :dir
    attr_accessor :priority # num from 1 to 5 (VH, H, M, L, VL)
    attr_accessor :categories # pipe-separated string
    attr_accessor :description
    attr_accessor :notes # optional
    attr_accessor :owner
    attr_accessor :is_known_issue # optional
    attr_accessor :known_issue_description  # optional




    def to_json
        h = {}
        h[:Name] = @name
        h[:Dir] = @dir
        h[:Priority] = @priority
        h[:Categories] = @categories
        h[:Description] = @description
        h[:Notes] = @notes
        h[:Owner] = @owner
        h[:IsKnownIssue] = @is_known_issue if @is_known_issue != nil
        h[:KnownIssueDescription] = @known_issue_description if @known_issue_description != nil

        JSON.pretty_generate(h)
    end

    alias :to_s :to_json

end

require 'auditor/version'
require 'auditor/database'
require 'auditor/scanner'
require 'auditor/grouped_result'

module Auditor
  class Auditor
    def self.audit(directories)
      auditor = new

      directories.each do |directory|
        auditor.check(directory)
      end

      auditor.results
    end

    def initialize
      @results = []
      @scanner = Scanner.new
    end

    def check(directory)
      @results.concat(@scanner.scan(directory))
    end

    def results
      @results.group_by(&:identifier).map do |_, results|
        GroupedResult.new(results)
      end
    end
  end
end

require 'security_report/version'
require 'security_report/database'
require 'security_report/scanner'
require 'security_report/grouped_result'

module SecurityReport
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

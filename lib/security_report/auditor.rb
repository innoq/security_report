require 'security_report/scanner'
require 'security_report/grouped_result'

module SecurityReport
  class Auditor
    def self.audit(directories)
      auditor = self.new

      directories.each do |directory|
        auditor.check(directory)
      end

      auditor
    end

    attr_reader :skipped

    def initialize
      @results = []
      @skipped = []
      @scanner = Scanner.new
    end

    def check(directory)
      @results.concat(@scanner.scan(directory))
    rescue Errno::ENOENT, Bundler::GemfileLockNotFound
      @skipped.push(directory)
    end

    def results
      @results.group_by(&:identifier).map do |_, results|
        GroupedResult.new(results)
      end
    end
  end
end

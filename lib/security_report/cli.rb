require 'security_report'

module SecurityReport
  class CLI
    attr_accessor :format

    def initialize
      @format = "plain"
    end

    def help
      puts <<~HELPTEXT
        security_report [options] files...

        -h, --help
          Print this message
        --format
          Provide the format: plain or table (default: plain)
        --update
          Update the vulnerability database before running
      HELPTEXT
      exit
    end

    def reporter
      case format
      when "plain"
        require 'security_report/plain_reporter'
        @reporter = PlainReporter.new
      when "table"
        require 'security_report/table_reporter'
        @reporter = TableReporter.new
      else
        puts "Unknown format '#{format}'"
        exit 1
      end
    end

    def update
      return if Database.update
      puts "Failed updating database!"
      exit 1
    end

    def run(files)
      auditor = Auditor.audit(files)
      reporter.report(auditor.results, auditor.skipped)
      exit 1 if auditor.results.any?
    end
  end
end

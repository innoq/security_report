require 'security_report'

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
      @reporter = SecurityReport::PlainReporter.new
    when "table"
      require 'security_report/table_reporter'
      @reporter = SecurityReport::TableReporter.new
    else
      puts "Unknown format '#{format}'"
      exit 1
    end
  end

  def update
    return if SecurityReport::Database.update
    puts "Failed updating database!"
    exit 1
  end

  def run(files)
    results = SecurityReport::Auditor.audit(files)
    reporter.report(results)
    exit 1 if results.any?
  end
end

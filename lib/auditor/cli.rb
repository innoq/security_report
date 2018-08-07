require 'auditor'

class CLI
  attr_accessor :format

  def initialize
    @format = "table"
  end

  def help
    puts <<~HELPTEXT
      auditor [options] files...

      -h, --help
        Print this message
      --format
        Provide the format: table (default: table)
      --update
        Update the vulnerability database before running
    HELPTEXT
    exit
  end

  def reporter
    case format
    when "table"
      require 'auditor/table_reporter'
      @reporter = Auditor::TableReporter.new
    else
      puts "Unknown format '#{format}'"
      exit 1
    end
  end

  def update
    return if Auditor::Database.update
    puts "Failed updating database!"
    exit 1
  end

  def run(files)
    results = Auditor::Auditor.audit(files)
    reporter.report(results)
    exit 1 if results.any?
  end
end

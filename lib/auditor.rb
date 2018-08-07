require 'auditor/version'
require 'fileutils'
require 'pathname'
require 'bundler/audit/scanner'
require 'forwardable'

module Auditor
  class UnpatchedGemReport
    extend Forwardable

    attr_accessor :gem
    attr_accessor :advisory
    attr_reader :target

    def_delegators :advisory, :criticality

    def initialize(gem, advisory, target)
      @gem = gem
      @advisory = advisory
      @target = target
    end

    def identifier
      @gem.to_s
    end

    def more_information
      advisory.url
    end

    def problem
      id = if advisory.cve
             "CVE-#{advisory.cve}"
           elsif advisory.osvdb
             advisory.osvdb
           end
      "#{id} (#{truncate(advisory.title, 30)})"
    end

    def solution
      if advisory.patched_versions.empty?
        "Remove or disable this gem until a patch is available!"
      else
        "Upgrade to a new version"
      end
    end

    private

    def truncate(string, max)
      string.length > max ? "#{string[0...max].strip}..." : string
    end
  end

  class InsecureSourceResult
    attr_accessor :source
    attr_reader :target

    def initialize(source, target)
      @source = source
      @target = target
    end

    def identifier
      @source
    end

    def problem
      "Do not use an insecure Source URI"
    end

    def more_information
      ""
    end

    def solution
      "Use a secure URI"
    end

    def criticality
      :high
    end
  end

  class GroupedResult
    def initialize(results)
      @results = results
    end

    def identifier
      @results.first.identifier
    end

    def target
      @results.map(&:target).uniq.join(", ")
    end

    def problem
      @results.map(&:problem).join("\n")
    end

    def more_information
      @results.map(&:more_information).join("\n")
    end

    def solution
      @results.map(&:solution).uniq.join(", ")
    end

    def criticality
      criticalities = @results.map(&:criticality).uniq
      return :high if criticalities.include? :high
      return :medium if criticalities.include? :high
      :low
    end
  end

  class Auditor
    def self.audit(directories)
      auditor = new

      directories.each do |directory|
        auditor.check(directory)
      end

      auditor.results.group_by(&:identifier).map { |_, res| GroupedResult.new(res) }
    end

    # Update the Audit Database
    def self.update
      unless ::Bundler::Audit::Database.update!(quiet: true)
        puts "Failed updating ruby-advisory-db!"
        exit 1
      end
    end

    attr_accessor :results

    def initialize
      @results = []
    end

    def check(directory)
      scanner = with_gemfile do
        ::Bundler::Audit::Scanner.new(directory)
      end

      results.concat(scanner.scan.map do |result|
        case result
        when ::Bundler::Audit::Scanner::InsecureSource
          InsecureSourceResult.new(result.source, directory)
        when ::Bundler::Audit::Scanner::UnpatchedGem
          UnpatchedGemReport.new(result.gem, result.advisory, directory)
        end
      end)
    end

    private

    # This is a weird workaround, for methods that
    # require a Gemfile in the current directory
    def with_gemfile
      if File.exist? 'Gemfile'
        yield
      else
        FileUtils.touch 'Gemfile'
        return_value = yield
        FileUtils.rm 'Gemfile'
        return_value
      end
    end
  end
end

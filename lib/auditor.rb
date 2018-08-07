require 'auditor/version'
require 'fileutils'
require 'bundler/audit/scanner'
require 'auditor/database'
require 'auditor/unpatched_gem_result'
require 'auditor/insecure_source_result'
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

    # Update the Audit Database
    def initialize
      @results = []
    end

    def check(directory)
      scanner = with_gemfile do
        ::Bundler::Audit::Scanner.new(directory)
      end

      @results.concat(scanner.scan.map do |result|
        case result
        when ::Bundler::Audit::Scanner::InsecureSource
          InsecureSourceResult.new(result.source, directory)
        when ::Bundler::Audit::Scanner::UnpatchedGem
          UnpatchedGemResult.new(result.gem, result.advisory, directory)
        end
      end)
    end

    def results
      @results.group_by(&:identifier).map { |_, res| GroupedResult.new(res) }
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

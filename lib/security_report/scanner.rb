require 'fileutils'
require 'bundler/audit/scanner'
require 'security_report/unpatched_gem_result'
require 'security_report/insecure_source_result'

module SecurityReport
  class Scanner
    def scan(directory)
      results = with_gemfile do
        ::Bundler::Audit::Scanner.new(directory).scan
      end

      results.map do |scan_result|
        detected_matching_result_class(scan_result).new(scan_result, directory)
      end
    end

    private

    # This is a weird workaround for methods that
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

    def detected_matching_result_class(scan_result)
      [InsecureSourceResult, UnpatchedGemResult].detect do |result_class|
        result_class.matches? scan_result
      end
    end
  end
end

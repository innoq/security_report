require 'forwardable'
require 'security_report/problem'

module SecurityReport
  class UnpatchedGemResult
    extend Forwardable

    attr_reader :identifier
    attr_reader :target

    def_delegator :advisory, :criticality

    def initialize(scan_result, target)
      @identifier = scan_result.gem.to_s
      @advisory = scan_result.advisory
      @target = target
    end

    def problem
      Problem.new(problem_id, advisory.title, advisory.url)
    end

    def solution
      if advisory.patched_versions.empty?
        "Remove or disable this gem until a patch is available!"
      else
        "Upgrade to a new version"
      end
    end

    def self.matches?(obj)
      obj.instance_of? ::Bundler::Audit::Scanner::UnpatchedGem
    end

    private

    attr_reader :advisory

    def problem_id
      if advisory.cve
        "CVE-#{advisory.cve}"
      elsif advisory.osvdb
        advisory.osvdb
      end
    end
  end
end

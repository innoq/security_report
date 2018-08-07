require 'forwardable'
require 'auditor/problem'

module Auditor
  class UnpatchedGemReport
    extend Forwardable

    attr_reader :identifier
    attr_reader :target

    def_delegator :advisory, :criticality

    def initialize(gem_specification, advisory, target)
      @identifier = gem_specification.to_s
      @advisory = advisory
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

module Auditor
  class InsecureSourceResult
    attr_reader :identifier
    attr_reader :target

    def initialize(source, target)
      @identifier = source
      @target = target
    end

    def problem
      Problem.new("Insecure URI", "Do not use an insecure Source URI", nil)
    end

    def solution
      "Use a secure URI"
    end

    def criticality
      :high
    end
  end
end

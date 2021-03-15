module SecurityReport
  class InsecureSourceResult
    attr_reader :identifier
    attr_reader :target

    def initialize(scan_result, target)
      @identifier = scan_result.source
      @target = target
    end

    def problem
      Problem.new("Insecure URI", "Do not use an insecure Source URI", nil)
    end

    def solution
      "Use a secure URI (https)"
    end

    def criticality
      :high
    end

    def self.matches?(obj)
      obj.instance_of? ::Bundler::Audit::Results::InsecureSource
    end
  end
end

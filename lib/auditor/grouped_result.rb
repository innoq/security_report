module Auditor
  class GroupedResult
    def initialize(results)
      @results = results
    end

    def identifier
      @results.first.identifier
    end

    def targets
      @results.map(&:target).uniq
    end

    def problem
      @results.map(&:problem).join("\n")
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
end

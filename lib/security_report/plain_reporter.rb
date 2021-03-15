module SecurityReport
  class PlainReporter
    def report(results, skipped)
      if results.any?
        high, medium_or_lower = results.partition { |result| result.criticality == :high }
        medium, low_or_unknown = medium_or_lower.partition { |result| result.criticality == :medium }

        [high, medium, low_or_unknown].each do |results|
          puts format_results(results) if results.any?
        end
      else
        puts "No vulnerabilities found"
      end

      if skipped.any?
        puts
        puts "Skipped #{skipped.join(", ")}: No Gemfile.lock found"
      end
    end

    private

    def format_results(results)
      results.map do |result|
        <<~HELPTEXT

        # #{result.identifier}

        Projects:    #{result.targets.join(", ")}
        Criticality: #{result.criticality}
        Solution:    #{result.solution}

        Problems:
        #{format_problems(result.problems)}
        HELPTEXT
      end.join("\n") + "\n"
    end

    def format_problems(problems)
      problems.map do |problem|
        " * #{problem.summary}"
      end.join("\n")
    end
  end
end

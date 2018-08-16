require 'terminal-table'

module SecurityReport
  class TableReporter
    def report(results, skipped)
      if results.any?
        high, medium_or_lower = results.partition { |result| result.criticality == :high }
        medium, low_or_unknown = medium_or_lower.partition { |result| result.criticality == :medium }

        puts tableize("High criticality", high) if high.any?
        puts tableize("Medium criticality", medium) if medium.any?
        puts tableize("Low or unknown criticality", low_or_unknown) if low_or_unknown.any?
        puts
        puts "Vulnerabilities (#{high.size} high, #{medium.size} medium, #{low_or_unknown.size} low or unkown) found!"
      else
        puts "No vulnerabilities found"
      end

      if skipped.any?
        puts "Skipped #{skipped.join(", ")}: No Gemfile.lock found"
      end
    end

    private

    def tableize(title, results)
      Terminal::Table.new(
        title: title,
        headings: ['Identifier', 'Target', 'Solution', 'Problem'],
        rows: results.map do |result|
          [
            result.identifier,
            result.targets.join(", "),
            result.solution,
            result.problems.map(&:summary).join("\n")
          ]
        end
      )
    end
  end
end

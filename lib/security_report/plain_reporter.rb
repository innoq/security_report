module SecurityReport
  class PlainReporter
    def report(results)
      results.each do |result|
        puts "# #{result.identifier}"
        puts "Projects: #{ result.targets.join(", ") }"
        puts "Solution: #{result.solution}"
        puts "Problems:"
        result.problems.each do |problem|
          puts "* #{problem.summary}"
        end
        puts
      end
    end
  end
end

require 'fileutils'

RSpec.describe SecurityReport do
  context "in our example" do
    let(:example) { %w[spec/examples/project_1 spec/examples/project_2] }

    it "finds the results with high criticality" do
      results = SecurityReport::Auditor.audit(example)

      results_with_high_criticality = results.select { |result| result.criticality == :high }
      expect(results_with_high_criticality.map(&:identifier)).to contain_exactly("paperclip (2.8.0)", "rubyzip (1.1.7)", "http://rubygems.org/", "nokogiri (1.6.7-java)")
    end

    it "finds zero results with medium criticality" do
      results = SecurityReport::Auditor.audit(example)

      results_with_medium_criticality = results.select { |result| result.criticality == :medium }
      expect(results_with_medium_criticality.length).to be 0
    end

    it "finds the results with low criticality" do
      results = SecurityReport::Auditor.audit(example)

      results_with_low_criticality = results.select { |result| result.criticality == :low }
      expect(results_with_low_criticality.map(&:identifier)).to contain_exactly("jquery-rails (3.0.4)", "rest-client (1.6.7)", "sprockets (2.2.3)", "uglifier (2.4.0)")
    end

    it "finds an insecure gem source" do
      results = SecurityReport::Auditor.audit(example)

      insecure_gem_source_result = results.detect { |result| result.identifier == "http://rubygems.org/" }
      expect(insecure_gem_source_result.targets).to eq ["spec/examples/project_2"]
      expect(insecure_gem_source_result.problems.first.summary).to eq "Insecure URI (Do not use an insecure Source...)"
      expect(insecure_gem_source_result.solution).to eq "Use a secure URI"
      expect(insecure_gem_source_result.criticality).to eq :high
    end

    it "finds the insecure paperclip version" do
      results = SecurityReport::Auditor.audit(example)

      insecure_gem_source_result = results.detect { |result| result.identifier == "paperclip (2.8.0)" }
      expect(insecure_gem_source_result.targets).to eq ["spec/examples/project_1"]
      expect(insecure_gem_source_result.problems.map(&:summary)).to contain_exactly("CVE-2017-0889 (Paperclip ruby gem suffers fro...)", "CVE-2015-2963 (Paperclip Gem for Ruby vulnera...)", "103151 (Paperclip Gem for Ruby contain...)")
      expect(insecure_gem_source_result.solution).to eq "Upgrade to a new version"
      expect(insecure_gem_source_result.criticality).to eq :high
    end
  end
end
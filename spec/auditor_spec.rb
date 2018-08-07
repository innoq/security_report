require 'fileutils'

RSpec.describe Auditor do
  context "in our example" do
    let(:example) { %w[spec/examples/project_1 spec/examples/project_2] }

    it "finds the results with high criticality" do
      results = Auditor::Auditor.audit(example)

      results_with_high_criticality = results.select { |result| result.criticality == :high }
      expect(results_with_high_criticality.map(&:identifier)).to contain_exactly("paperclip (2.8.0)", "rubyzip (1.1.7)", "http://rubygems.org/", "nokogiri (1.6.7-java)")
    end

    it "finds zero results with medium criticality" do
      results = Auditor::Auditor.audit(example)

      results_with_medium_criticality = results.select { |result| result.criticality == :medium }
      expect(results_with_medium_criticality.length).to be 0
    end

    it "finds the results with low criticality" do
      results = Auditor::Auditor.audit(example)

      results_with_low_criticality = results.select { |result| result.criticality == :low }
      expect(results_with_low_criticality.map(&:identifier)).to contain_exactly("jquery-rails (3.0.4)", "rest-client (1.6.7)", "sprockets (2.2.3)", "uglifier (2.4.0)")
    end

    it "finds an insecure gem source" do
      results = Auditor::Auditor.audit(example)

      insecure_gem_source_result = results.detect { |result| result.identifier == "http://rubygems.org/" }
      expect(insecure_gem_source_result.target).to eq "spec/examples/project_2"
      expect(insecure_gem_source_result.problem).to eq "Do not use an insecure Source URI"
      expect(insecure_gem_source_result.solution).to eq "Use a secure URI"
      expect(insecure_gem_source_result.criticality).to eq :high
    end

    it "finds the insecure paperclip version" do
      results = Auditor::Auditor.audit(example)

      insecure_gem_source_result = results.detect { |result| result.identifier == "paperclip (2.8.0)" }
      expect(insecure_gem_source_result.target).to eq "spec/examples/project_1"
      expect(insecure_gem_source_result.problem).to include "CVE-2017-0889"
      expect(insecure_gem_source_result.problem).to include "CVE-2015-2963"
      expect(insecure_gem_source_result.problem).to include "103151"
      expect(insecure_gem_source_result.solution).to eq "Upgrade to a new version"
      expect(insecure_gem_source_result.criticality).to eq :high
      expect(insecure_gem_source_result.more_information).to include "https://robots.thoughtbot.com/paperclip-security-release"
    end
  end
end

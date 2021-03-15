require 'fileutils'

RSpec.describe SecurityReport do
  context "in our example" do
    let(:example) { %w[spec/examples/project_1 spec/examples/project_2 spec/examples/project_3] }

    before(:all) do
      SecurityReport::Database.update
    end

    it "finds the results with high criticality" do
      results = SecurityReport::Auditor.audit(example).results

      results_with_high_criticality = results.select { |result| result.criticality == :high }
      expect(results_with_high_criticality.map(&:identifier)).to contain_exactly("paperclip (2.8.0)", "http://rubygems.org/", "nokogiri (1.6.7-java)", "rake (12.0.0)")
    end

    it "finds the results with medium criticality" do
      results = SecurityReport::Auditor.audit(example).results

      results_with_medium_criticality = results.select { |result| result.criticality == :medium }
      expect(results_with_medium_criticality.map(&:identifier)).to contain_exactly("haml (4.0.4)", "haml (4.0.7)", "jquery-rails (3.0.4)", "jquery-rails (3.1.4)", "jquery-ui-rails (4.1.0)")
    end

    it "finds the results with low criticality" do
      results = SecurityReport::Auditor.audit(example).results

      results_with_low_criticality = results.select { |result| result.criticality == :low }
      expect(results_with_low_criticality.map(&:identifier)).to contain_exactly("rest-client (1.6.7)", "sprockets (2.2.3)", "uglifier (2.4.0)", "actionpack (3.2.22.5)", "activeresource (3.2.22.5)", "activesupport (3.2.22.5)", "json (1.8.6-java)", "mechanize (2.7.5)", "rack (1.4.7)", "rubyzip (1.1.7)")
    end

    it "finds an insecure gem source" do
      results = SecurityReport::Auditor.audit(example).results

      insecure_gem_source_result = results.detect { |result| result.identifier == "http://rubygems.org/" }
      expect(insecure_gem_source_result.targets).to eq ["spec/examples/project_2"]
      expect(insecure_gem_source_result.problems.first.summary).to eq "Insecure URI (Do not use an insecure Sour...)"
      expect(insecure_gem_source_result.solution).to eq "Use a secure URI (https)"
      expect(insecure_gem_source_result.criticality).to eq :high
    end

    it "finds the insecure paperclip version" do
      results = SecurityReport::Auditor.audit(example).results

      insecure_gem_source_result = results.detect { |result| result.identifier == "paperclip (2.8.0)" }
      expect(insecure_gem_source_result.targets).to eq ["spec/examples/project_1"]
      expect(insecure_gem_source_result.problems.map(&:summary)).to contain_exactly("https://cve.circl.lu/cve/CVE-2017-0889 (Paperclip ruby gem suffers...)", "https://cve.circl.lu/cve/CVE-2015-2963 (Paperclip Gem for Ruby vuln...)", "103151 (Paperclip Gem for Ruby cont...)")
      expect(insecure_gem_source_result.solution).to eq "Upgrade to a new version"
      expect(insecure_gem_source_result.criticality).to eq :high
    end

    it "notices skipped projects" do
      skipped = SecurityReport::Auditor.audit(example).skipped

      expect(skipped).to eq ["spec/examples/project_3"]
    end
  end
end

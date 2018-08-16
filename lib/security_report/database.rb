require 'bundler/audit/database'

module SecurityReport
  module Database
    def self.update
      ::Bundler::Audit::Database.update!(quiet: true)
    end
  end
end

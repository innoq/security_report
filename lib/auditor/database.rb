require 'bundler/audit/database'

module Auditor
  module Database
    def self.update
      ::Bundler::Audit::Database.update!(quiet: true)
    end
  end
end

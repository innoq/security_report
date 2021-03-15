module SecurityReport
  class Problem
    def initialize(identifier, description, url)
      @identifier = identifier
      @description = description
      @url = url
    end

    def summary
      "#{@identifier} (#{truncate(@description, 30)})"
    end

    private

    def truncate(string, max)
      string.length > max ? "#{string[0 ... max - 3].strip}..." : string
    end
  end
end

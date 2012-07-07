module Jekyll
  class Site
    alias_method :accessor_site_payload, :site_payload
    attr_accessor :payload

    def site_payload
      return @payload if @payload

      @payload = accessor_site_payload
      @payload
    end
  end
end
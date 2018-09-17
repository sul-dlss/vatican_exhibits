module ApiAuthorization
  ##
  # Constraint used gate API access to annotations
  class Constraint
    def matches?(request)
      return true if request.get? || valid_api_key?(request)

      raise ApiAuthorization::Unauthorized
    end

    def valid_api_key?(request)
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(request.headers['Authorization'].to_s),
        ::Digest::SHA256.hexdigest(Settings.annotations.api_key.to_s)
      )
    end
  end
end

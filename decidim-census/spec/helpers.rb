module Decidim
  module Census
    module Helpers
      def encode_id_document(id_document)
        Digest::MD5.hexdigest(
          "#{id_document}-#{Rails.application.secrets.secret_key_base}"
        )
      end
    end
  end
end

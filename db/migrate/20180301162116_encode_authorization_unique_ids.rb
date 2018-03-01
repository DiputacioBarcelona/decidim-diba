class EncodeAuthorizationUniqueIds < ActiveRecord::Migration[5.1]
  def up
    ActiveRecord::Base.connection.execute(
      'LOCK decidim_authorizations IN ACCESS EXCLUSIVE MODE'
    )
    Decidim::Authorization.find_each do |authorization|
      encoded_unique_id = Digest::MD5.hexdigest(
        "#{authorization.unique_id}-#{Rails.application.secrets.secret_key_base}"
      )
      authorization.update(unique_id: encoded_unique_id)
    end
  end
end

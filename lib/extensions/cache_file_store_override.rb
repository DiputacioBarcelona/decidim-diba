# frozen_string_literal: true

module CacheFileStoreOverride
  extend ActiveSupport::Concern

  # This is a fix included in Rails since version 7.0. This is required to
  # avoid errors trying to clear cache using Rails.cache.delete_matched when
  # cache uses ActiveSupport::Cache::FileStore and long cache keys are used
  #
  # See: https://github.com/rails/rails/pull/49694
  # Related: https://github.com/rails/rails/issues/49690
  included do
    # Translate a file path into a key.
    def file_path_key(path)
      fname = path[cache_path.to_s.size..-1].split(File::SEPARATOR, 4).last.delete(File::SEPARATOR)
      URI.decode_www_form_component(fname, Encoding::UTF_8)
    end
  end
end

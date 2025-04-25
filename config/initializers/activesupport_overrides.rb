# frozen_string_literal: true

require "extensions/cache_file_store_override"

Rails.application.config.to_prepare do
  if ActiveSupport.version < "7.0"
    ActiveSupport::Cache::FileStore.include(CacheFileStoreOverride)
  else
    ::Kernel.warn("Remove the ActiveSupport::Cache::FileStore override because the current ActiveSupport version (#{ActiveSupport.version.version}) includes this fix")
  end
end

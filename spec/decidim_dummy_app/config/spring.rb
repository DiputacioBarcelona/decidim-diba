# https://github.com/rails/spring/issues/323#issuecomment-68302270
Spring.application_root = ''

%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
].each { |path| Spring.watch(path) }

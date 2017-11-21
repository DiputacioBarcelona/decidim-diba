require 'spec_helper'

class AuthorizerStub

  def initialize(date, age)
    @date = date
    @age = age
  end

  def authorization_handler_name
    'census_authorization_handler'
  end

  def authorization
    OpenStruct.new(metadata: { 'birthdate' => @date })
  end

  def permission_options
    @age ? { 'edad' => @age } : {}
  end

  def status(code, options = nil)
    { code: code, options: options }
  end

end
AuthorizerStub.prepend Decidim::Census::Extensions::AuthorizeWithAge

RSpec.describe Decidim::Census::Extensions::AuthorizeWithAge do
  it 'authorizes with age metadata' do
    authorizer = AuthorizerStub.new('1970/11/21', '20')
    expect(authorizer.authorize[:code]).to be :ok
  end

  it 'uses 18 as default age when not present' do
    old = 18.years.ago.strftime('%Y/%m/%d')
    auth_old = AuthorizerStub.new(old, nil)
    expect(auth_old.authorize[:code]).to be :ok

    young = 17.years.ago.strftime('%Y/%m/%d')
    auth_young = AuthorizerStub.new(young, nil)
    expect(auth_young.authorize[:code]).to be :invalid
  end
end

require 'spec_helper'

class AuthorizerStub

  attr_reader :authorization

  def initialize(age:, authorization: nil)
    @age = age
    @authorization = authorization
  end

  def authorization_handler_name
    'census_authorization_handler'
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
    authorizer = AuthorizerStub.new(age: '20',
                                    authorization: authorization_for('1970/11/21'))
    expect(authorizer.authorize[:code]).to be :ok
  end

  it 'uses 18 as default age when not present' do
    old = 18.years.ago.strftime('%Y/%m/%d')
    auth_old = AuthorizerStub.new(age: nil,
                                  authorization: authorization_for(old))
    expect(auth_old.authorize[:code]).to be :ok

    young = 17.years.ago.strftime('%Y/%m/%d')
    auth_young = AuthorizerStub.new(age: nil,
                                    authorization: authorization_for(young))
    expect(auth_young.authorize[:code]).to be :invalid
  end

  it 'does not authorize the user if the authorization is not present' do
    authorizer_without_authorization = AuthorizerStub.new(age: nil,
                                                          authorization: nil)

    expect(authorizer_without_authorization.authorize[:code]).to be :missing
  end

  def authorization_for(date)
    OpenStruct.new(metadata: { 'birthdate' => date })
  end
end

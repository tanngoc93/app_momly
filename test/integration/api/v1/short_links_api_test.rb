require 'test_helper'

class ApiV1ShortLinksApiTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: 'user@example.com', password: 'password')
    @token = @user.api_token
    @link = ShortLink.create!(user: @user, original_url: 'https://example.com')
  end

  test 'index lists short links' do
    ShortLink.create!(user: @user, original_url: 'https://two.example.com')

    get '/api/v1/short_links', headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :success

    body = JSON.parse(@response.body)
    assert_equal 2, body['data'].length
    assert_equal 1, body['pagy']['page']
    assert body['pagy']['pages'] >= 1
    assert_equal 2, body['pagy']['count']
  end

  test 'show returns short link' do
    get "/api/v1/short_links/#{@link.id}", headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :success

    body = JSON.parse(@response.body)
    assert_equal @link.short_code, body['data']['short_code']
  end

  test 'update modifies short link' do
    patch "/api/v1/short_links/#{@link.id}",
          params: { original_url: 'https://new.example.com' },
          headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :success

    @link.reload
    assert_equal 'https://new.example.com', @link.original_url
  end

  test 'destroy removes short link' do
    delete "/api/v1/short_links/#{@link.id}", headers: { 'Authorization' => "Bearer #{@token}" }
    assert_response :no_content

    assert_nil ShortLink.find_by(id: @link.id)
  end
end

# frozen_string_literal: true

class Rack::Attack
  # Throttle sign-up requests:
  # Allow up to 10 POST /register requests per IP in 1 hour
  throttle('limit signups per ip', limit: 10, period: 1.hour) do |req|
    # Check if the request is a POST to the /register path
    if req.path == '/register' && req.post?
      req.ip
    end
  end

  # Throttle admin login requests:
  # Allow up to 10 POST /admin/login requests per IP in 1 hour
  throttle('limit admin login per ip', limit: 10, period: 1.hour) do |req|
    # Check if the request is a POST to the /admin/login path
    if req.path == '/admin/login' && req.post?
      req.ip
    end
  end

  # This block defines the custom response when throttled
  self.throttled_response = lambda do |env|
    # 429: HTTP status code "Too Many Requests"
    [
      429,
      { 'Content-Type' => 'text/plain' },
      ["Too many requests from this IP address. You have exceeded the allowed limit of requests per hour. Please wait for 1 hour before trying again.\n"]
    ]
  end
end

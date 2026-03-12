require "../../src/rod"
require "http/client"
require "uri"

# An example to handle stripe 3DS callback.
def post(path : String, body : String) : JSON::Any
  stripe_key = ENV["STRIPE_TEST_SECRET_KEY"]? || raise "Set STRIPE_TEST_SECRET_KEY to run this example"
  headers = HTTP::Headers{
    "Authorization" => "Bearer #{stripe_key}",
    "Content-Type"  => "application/x-www-form-urlencoded",
  }
  response = HTTP::Client.post("https://api.stripe.com/v1#{path}", headers: headers, body: body)
  JSON.parse(response.body)
end

def get_redirect_url : String
  token = post("/tokens", "card[number]=4000000000003220&card[exp_month]=7&card[exp_year]=2025&card[cvc]=314")["id"].as_s
  post(
    "/payment_intents",
    "amount=100&currency=usd&payment_method_data[type]=card&confirm=true&return_url=https%3A%2F%2Fmdn.dev&payment_method_data[card][token]=#{URI.encode_path_segment(token)}"
  )["next_action"]["redirect_to_url"]["url"].as_s
end

page = Rod::Browser.new.must_connect.must_page(get_redirect_url)
frame01 = page.must_element("div iframe").must_frame
frame02 = frame01.must_element("#challengeFrame").must_frame
btn = frame02.must_element_r("button", "COMPLETE").must_wait_stable
wait = frame02.must_wait_request_idle
btn.must_click
wait.call

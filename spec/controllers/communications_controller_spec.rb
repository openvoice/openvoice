require 'spec_helper'

describe CommunicationsController do
  before do
    IncomingCall.stub(:create)
  end

  describe "#handle_incoming_call" do
    it "should signal callee to hangup when caller hangs up" do
      expected_hash = {"event"=>"hangup", "next"=>"/incoming_calls/signal_peer"}
      post :handle_incoming_call, valid_incoming_call_params
      response.should be_success
      json_response = JSON.parse(response.body)
      json_response["tropo"].to_a.detect{|elem| elem["on"] == expected_hash}.should_not be_nil
    end
  end

  def valid_incoming_call_params
    {
      "result" => {"sequence" => 2,
                   "callId"=>"825c9b76681b216ce041ff727b5a33b0",
                   "complete"=>true,
                   "sessionId"=>"5be8f7a5815584e1d0bb362c56ce6165",
                   "error"=>nil,
                   "sessionDuration"=>3,
                   "state"=>"ANSWERED"},
      "session_id"=>"5be8f7a5815584e1d0bb362c56ce6165",
      "user_id"=>"6",
      "call_id"=>"825c9b76681b216ce041ff727b5a33b0",
      "caller_id"=>"07801104386"}
  end
end
class CallsController < ApplicationController
  before_filter :require_user, :only => [:index]

  def index
    @calls = current_user.incoming_calls + current_user.outgoing_calls
    @calls.sort! {|a, b| a.updated_at <=> b.updated_at}
    @calls.reverse!
    @calls = @calls.paginate(:page => params[:page], :per_page => 15)
  end
end

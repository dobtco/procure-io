include ApplicationHelper

class FakeUserSession
  def initialize(user_id)
    class_eval %Q{
      def record
        User.find(#{user_id})
      end
    }
  end
end

def sign_in(user)
  UserSession.stub!(:find).and_return(FakeUserSession.new(user.id))
end

def sign_out
  UserSession.stub!(:find).and_return(nil)
end

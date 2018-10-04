require 'test_helper'

module ApiAuthentication
  class AccountMailerTest < ActionMailer::TestCase
    test "recovery" do
      mail = AccountMailer.recovery
      assert_equal "Recovery", mail.subject
      assert_equal ["to@example.org"], mail.to
      assert_equal ["from@example.com"], mail.from
      assert_match "Hi", mail.body.encoded
    end

  end
end

require 'test/garmin_test_setup'

class TestActivity < Test::Unit::TestCase
  context "building" do
    should "have a sport" do
      a = Garmin::Activity.new
      a.sport = "Running"
      assert_equal "Running", a.sport
    end
  end

  should "have a date" do
    a = Garmin::Activity.new
    t = Time.now
    a.date = t
    assert_equal t, a.date
  end
  
  should "have a distance" do
    a = Garmin::Activity.new
    a.distance = 325.5
    assert_equal 325.5, a.distance
  end
end
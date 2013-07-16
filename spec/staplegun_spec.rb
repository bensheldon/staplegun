require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Staplegun" do
  describe "new" do

    context "successful login" do
      before :each do
        VCR.use_cassette('login_successful') do
          @stapler = Staplegun.login :email => "tester@test.com", :password => "correctpassword"
        end
      end

      it "logs in" do
        puts @stapler.inspect
      end
    end

    context "unsuccessful login" do
      it "logs in" do
        VCR.use_cassette('login_unsucessful') do
          expect { @stapler = Staplegun.login! :email => "tester@test.com", :password => "incorrectpassword" }.to raise_error Mechanize::UnauthorizedError
        end
      end
    end
  end

  describe "pin" do
    before :each do
      VCR.use_cassette('login_successful') do
        @stapler = Staplegun.login :email => "tester@test.com", :password => "incorrectpassword"
      end
    end

    it "works" do
      pin = {
        :board_id => "163537098907877805",
        :link => "http://dayoftheshirt.com/shirts/U6erEgibsVDq/angry-paisley",
        :image_url => "http://d1sct75hbeauoh.cloudfront.net/images/shirts/U6erEgibsVDq/shirtbattle_angry-paisley.full.png",
        :description => "ANGRY PAISLEY by Zomboy"
      }

      VCR.use_cassette('pin_successful') do
        @stapler.pin(pin)
      end
    end

  end

  describe "generate_pin_url" do
    before :each do
      VCR.use_cassette('login_successful') do
        @stapler = Staplegun.login :email => "tester@test.com", :password => "incorrectpassword"
      end

      @pin = {
        :board_id => "163537098907877805",
        :link => "http://dayoftheshirt.com/shirts/U6erEgibsVDq/angry-paisley",
        :image_url => "http://d1sct75hbeauoh.cloudfront.net/images/shirts/U6erEgibsVDq/shirtbattle_angry-paisley.full.png",
        :description => "ANGRY PAISLEY by Zomboy"
      }
    end

    it "generates the proper pin form url" do
      url = @stapler.send(:generate_pin_url, @pin)
      url.should == "/pin/create/button/?url=http://dayoftheshirt.com/shirts/U6erEgibsVDq/angry-paisley&media=http://d1sct75hbeauoh.cloudfront.net/images/shirts/U6erEgibsVDq/shirtbattle_angry-paisley.full.png&description=ANGRY%20PAISLEY%20by%20Zomboy"
    end

    it "appends the domain if :domain => true" do
      url = @stapler.send(:generate_pin_url, @pin, :domain => true)
      url.should == "http://pinterest.com/pin/create/button/?url=http://dayoftheshirt.com/shirts/U6erEgibsVDq/angry-paisley&media=http://d1sct75hbeauoh.cloudfront.net/images/shirts/U6erEgibsVDq/shirtbattle_angry-paisley.full.png&description=ANGRY%20PAISLEY%20by%20Zomboy"
    end

    it "does not omit ?description= if not included in pin" do
      pin = @pin
      pin.delete :description

      url = @stapler.send(:generate_pin_url, pin)
      url.should == "/pin/create/button/?url=http://dayoftheshirt.com/shirts/U6erEgibsVDq/angry-paisley&media=http://d1sct75hbeauoh.cloudfront.net/images/shirts/U6erEgibsVDq/shirtbattle_angry-paisley.full.png"
    end
  end

end

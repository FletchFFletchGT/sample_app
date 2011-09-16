require 'spec_helper'

describe User do
  before(:each) do
    @attr = { 
      :name => "Example User", 
      :email => "user@name.com",
      :password => "foobar",
      :password_confirmation => "foobar"
      
      }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  
  it "should reject long names" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org foo@japan.co.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject duplicate uppercase email addresses" do
    User.create!(@attr)
    upcased_email = @attr[:email].upcase
    user_with_duplicate_upper_email = User.new(@attr.merge(:email => upcased_email))
    user_with_duplicate_upper_email.should_not be_valid
  end
  
  #testing password
  it "should require a password" do
    user_without_password = User.new(@attr.merge(:password => "", 
      :password_confirmation => ""))
    user_without_password.should_not be_valid
  end
  
  it "should reject short passwords" do
    shortpass = "a" * 5
    user_short_password = User.new(@attr.merge(:password => shortpass, 
      :password_confirmation => shortpass))
    user_short_password.should_not be_valid
  end
  
  it "should reject long passwords" do
    longpass = "a" * 41
    user_long_password = User.new(@attr.merge(:password => longpass, 
      :password_confirmation => longpass))
    user_long_password.should_not be_valid
  end
  
  it "should require password confirmation" do
    user_unconfirmed_password = User.new(@attr.merge(:password_confirmation => "invalid"))
    user_unconfirmed_password.should_not be_valid
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should not have a blank encrypted passwor" do
      @user.encrypted_password.should_not be_blank
    end
    
    it "should be true if the passwords match" do
      @user.has_password?(@attr[:password]).should be_true
    end
    
    it "should not be true if the passwords don't match" do
      @user.has_password?("invalid").should be_false
    end
    
    describe "authenticate method" do
      
      it "should return nil on bad email/password combination" do
        wrong_password_user = User.authenticate(@attr[:email], "invalid")
        wrong_password_user.should be_nil
      end
      
      it "should return nil for an email not in database" do
        nonexistent_user = User.authenticate("no@no.com", @attr[:password])
        nonexistent_user.should be_nil
      end
      
      it "should return a user for a valid email/password combination" do
        good_user = User.authenticate(@attr[:email], @attr[:password])
        good_user.should == @user
      end
    end
  end
  
  describe "micropost associations" do
    
    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end
    
    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    
    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should destroy microposts when users are deleted" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    
    describe "status feed" do
      
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      
      it "should include the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end
      
      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost, :user => (Factory(:user, 
            :email => Factory.next(:email), :created_at => 1.day.ago)))
        @user.feed.include?(mp3).should be_false
      end
    end
    
  end
  
end

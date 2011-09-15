Factory.define :user do |user|
  user.name "Jason Fletcher"
  user.email "jason.fletcher@gmail.com"
  user.password "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end
FactoryGirl.define do
  factory :application_redirect_uri do |aru|
    redirect_uri "https://app.com/callback"
  end
  
  factory :application do |application|
    sequence(:name){ |n| "Application #{n}" }
    application.after_create { |a| Factory(:application_redirect_uri, :application => a) }
  end

  factory :application_without_redirect_uris, :class => :application do |application|
    sequence(:name){ |n| "Application With No Redirects #{n}" }
    application.public true
  end

  factory :application_with_multiple_redirect_uris, :class => :application do |application|
    sequence(:name){ |n| "Application With Multiple Redirects #{n}" }
    application.after_create { |a| 
      Factory(:application_redirect_uri, :application => a) 
      Factory(:application_redirect_uri, :application => a, :redirect_uri => "https://app.com/other_callback") 
    }
  end
end

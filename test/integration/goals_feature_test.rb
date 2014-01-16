require './test/test_helper'

class GoalsFeatureTest < Capybara::Rails::TestCase

  setup do
    Capybara.current_driver = :selenium
    capybara_setup
    visit root_path
    click_link 'Log In'
  end

  test 'a goal and reminder can be added and viewed' do
    click_link 'Add Goal'
    assert page.has_css?('#create-goal-title')
    select('Github', :from => 'api_selection')
    select('1', :from => 'Target Goal')
    select('1', :from => 'Period')
    select('day', :from => 'Period Type')
    click_button "Submit Goal"
    assert page.has_css?('.goal-title')
    refute page.has_content?("Target")
    assert page.has_content?("Add Reminder")
    click_link "Add Reminder"
    assert page.has_css?(".reminder-submit-button")
    fill_in "Start date", :with => "01/09/2014"
    fill_in "Target", :with => "2"
    fill_in "Time deadline", :with => "4:00pm"
    fill_in "Day deadline", :with => "5"
    check "Twitter"
    check "Sms"
    check "Email"
    click_button "Create Reminder"
    assert page.has_content?('I am committing to reach 1 commit every 1 days')
    assert page.has_content?("I need to reach")
    assert page.has_css?(".view-reminder-link")
    click_link "I need to reach"
    assert page.has_css?("#reminder-show-page")
  end

end

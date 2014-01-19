require "test_helper"
require 'timecop'

class ExercismApiTest < ActiveSupport::TestCase

  def setup
    VCR.use_cassette('kytrinyx_nitpick', :record => :new_episodes) do
      @nitpicks = ExercismApiRequest.new(4, 18, "kytrinyx", "nitpick", "ruby")
      @submissions = ExercismApiRequest.new(1, 1, "thewatts", "submission", "ruby")
    end
  end

  def teardown
  end

  def test_valid_exercism_name
    VCR.use_cassette('invalic_checks', :record => :new_episodes) do
      invalid = ApiRequest.new('sdfefsf', 'exercism')
      refute invalid.valid_username_exercism?
      valid = ApiRequest.new('thewatts', 'exercism')
      assert valid.valid_username_exercism?
    end
  end

  def test_which_dates_returns_accurate_dates
    VCR.use_cassette('which_dates_calls', :record => :new_episodes) do
      Timecop.freeze(Date.today) do
        request1 = ExercismApiRequest.new(1, 1, "thewatts", "submission", "ruby")
        assert_equal ["2014/01"], request1.which_dates
        request2 = ExercismApiRequest.new(20, 1, "thewatts", "submission", "ruby")
        assert_equal ["2013/12", "2014/01"], request2.which_dates
        request3 = ExercismApiRequest.new(100, 1, "thewatts", "submission", "ruby")
        assert_equal ["2013/10", "2013/11", "2013/12", "2014/01"], request3.which_dates
      end
    end
  end

  def test_which_links_returns_correct_links
    VCR.use_cassette('kytrinyx_nitpick', :record => :new_episodes) do
      Timecop.freeze(Date.today) do
        correct_link = ["http://exercism.io/api/v1/stats/kytrinyx/nitpicks/2014/01"]
        assert_equal correct_link, @nitpicks.which_links(["2014/01"])
        multiple_links = ["http://exercism.io/api/v1/stats/kytrinyx/nitpicks/2013/10",
                         "http://exercism.io/api/v1/stats/kytrinyx/nitpicks/2013/11", 
                         "http://exercism.io/api/v1/stats/kytrinyx/nitpicks/2013/12", 
                         "http://exercism.io/api/v1/stats/kytrinyx/nitpicks/2014/01"]
        assert_equal multiple_links, @nitpicks.which_links(["2013/10", "2013/11", "2013/12", "2014/01"])
      end
    end
  end

  def test_start_date_returns_correct_number
    VCR.use_cassette('kytrinyx_nitpick', :record => :new_episodes) do
      Timecop.freeze(Date.today) do
        assert_equal 4, @nitpicks.days_to_pull
        assert_equal 'Sat, 18 Jan 2014'.to_date, Date.today
        assert_equal '14 Jan 2014'.to_date, @nitpicks.start_date
      end
    end
  end

  def test_generate_hash_renders_correct_format
    VCR.use_cassette('kytrinyx_nitpick', :record => :new_episodes) do
      Timecop.freeze(Date.today) do
        languages = ["clojure", "coffeescript", "elixir", "go", "haskell", "javascript", "objective-c", "ocaml", "perl5", "python", "ruby", "scala"]
        assert_equal languages, @nitpicks.generate_hash.first.keys
        days_in_the_month = 31
        assert_equal 31, @nitpicks.generate_hash.first['clojure'].count
        months = 1
        assert_equal months, @nitpicks.generate_hash.count
      end
    end
  end

  def test_generate_hash_handles_multiple_months
    VCR.use_cassette('kytrinyx_nitpick_large', :record => :new_episodes) do
      Timecop.freeze(Date.today) do
        @nitpicks_large = ExercismApiRequest.new(20, 1, "kytrinyx", "nitpick", "ruby")
        months = 2
        assert_equal months, @nitpicks_large.generate_hash.count
      end
    end
  end

  def test_get_array_by_language_handles_one_language
    VCR.use_cassette('kytrinyx_nitpick_large', :record => :new_episodes) do
      Timecop.freeze(Date.today) do
        nitpicks_large = ExercismApiRequest.new(20, 1, "kytrinyx", "nitpick", "ruby")
        clojure = nitpicks_large.get_array_by_language('clojure')
        ruby = nitpicks_large.get_array_by_language('ruby')
        refute_equal clojure, ruby
        assert_equal clojure.first['date'], ruby.first['date']
        refute_equal clojure.first['count'], ruby.first['count']
      end
    end
  end

  def test_get_array_by_any_language_functions
    VCR.use_cassette('kytrinyx_nitpick_large', :record => :new_episodes) do
      Timecop.freeze(Date.today) do
        nitpicks_large = ExercismApiRequest.new(20, 1, "kytrinyx", "nitpick", "ruby")
        any_language = nitpicks_large.get_array_by_language('any language')
        assert_equal 'boo', any_language
        # ruby = nitpicks_large.get_array_by_language('ruby')
        # refute_equal clojure, ruby
        # assert_equal clojure.first['date'], ruby.first['date']
        # refute_equal clojure.first['count'], ruby.first['count']
      end
    end
  end
end

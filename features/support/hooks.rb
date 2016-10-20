require 'watir-webdriver'
require 'pry'
#require 'data_magic'

#profile = Selenium::WebDriver::Firefox::Profile.new
#profile.native_events = false
#browser = Watir::Browser.new :firefox, :profile => profile
#browser.driver.manage.timeouts.implicit_wait = 5 # 5 seconds
#browser.driver.manage.window.maximize
#browser.goto ENV['URL']

#@controlData = YAML.load_file("features/support/data/controls.yml")
# binding.pry if ENV['DEBUG'] == true
   #profile = Selenium::WebDriver::Firefox::Profile.new
   ########### delete these couple of lines if chromedriver doesn;t work even after this#####
   puts __FILE__
   chromedriver_path=File.expand_path('../../driverDependencies/chromedriver.exe', File.dirname(__FILE__))
       ### Alternate way to set up the path ########
         #chromedriver_path=File.join(File.dirname(__FILE__), '../../driverDependencies',"chromedriver.exe")
         #chromedriver_path = File.join(File.absolute_path('H:\AccessibilityAutomation',File.dirname(__FILE__)),"driverDependencies","chromedriver.exe")
   profile=Selenium::WebDriver::Chrome.driver_path = chromedriver_path
   #profile = Selenium::WebDriver::Chrome::Profile.new

  # http://superuser.com/questions/697018/how-to-disable-popups-in-firefox-without-add-ons
  # h profile['browser.download.folderList'] = 2 #custom location
  # hprofile['browser.download.dir'] = "#{Dir.pwd}/results"
  # hprofile['browser.helperApps.neverAsk.saveToDisk'] = "application/text,application/zip"
  # hprofile['dom.popup_maximum'] = -1
  # hprofile['dom.successive_dialog_time_limit'] = -1

  if ENV['DEBUG'] != true
    (ENV['RESULTSDIR'].nil?) ? results_dir =  results_dir = "results/#{Time.now.strftime("%d%m%Y_%H%M%S")}" : results_dir = ENV['RESULTSDIR']
  end
  # Dir::mkdir(results_dir) if not File.directory?(results_dir)

  # profile['browser.helperApps.neverAsk.saveToDisk'] = "application/prs.qldtest"
  # download_directory.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?
  
  # comment it when change to chrome
  # profile.native_events = false

  #browser = Watir::Browser.new :firefox, :profile => profile
  #browser = Watir::Browser.new :chrome, :profile => profile, :switches => %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate]
  browser = Watir::Browser.new :chrome, :switches => %w[--disable-popup-blocking]

  browser.driver.manage.timeouts.implicit_wait = 5 # 5 seconds
  browser.driver.manage.window.maximize

  loggedIn = false
  baseurl = ENV['URL']
  envPrefix = ENV['ENV_PREFIX']
  testData = YAML.load_file("features/support/data/#{envPrefix}_testdata.yml") if(!envPrefix.nil?)
  log = Logger.new STDOUT
  log.level = Logger::WARN
  log.level = Logger::DEBUG if(!ENV['DEBUG'].nil?)
  log.formatter = proc { |severity, time, progname, msg|"#{severity} #{time} #{caller[4].split('/').last}> #{msg}\n"}
  
  timestamp = ENV['RESULTSDIR'].split("_")[1]

  # if(envPrefix != "nsw" || envPrefix != "vic")
  
    # cmdLine = "C:/kittylocal.exe @NTPD249"
    # log.info "Start sync time for #{envPrefix}: #{cmdLine}"

    # if(system(cmdLine))
    #   log.info "Sync Time DONE"
    # else 
    #   raise "Time cannot be synchronized"
    # end

  # end
  
  #@browser = browser
  #browser.goto ENV['URL']

Before do
  #Selenium::WebDriver::Firefox::Binary.path="C:/Program Files (x86)/Mozilla Firefox/firefox.exe"
  #@browser = Selenium::WebDriver.for :firefox

  $baseurl = baseurl
  $browser = browser
  $loggedIn = loggedIn
  $envPrefix = envPrefix
  $testData = testData
  $log = log
  $timestamp = timestamp
  puts "TimeStampPrefix is " + timestamp

  TestRun.browser.goto TestRun.baseurl if(!TestRun.loggedIn)
  #binding.pry
end

After do |scenario|

  begin
    if scenario.failed?
      Dir::mkdir('results/screenshots') if not File.directory?('results/screenshots')
      screenshot = "./results/screenshots/FAILED_#{scenario.name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png"
      #Browser::BROWSER.driver.save_screenshot(screenshot)
      TestRun.browser.driver.save_screenshot(screenshot)
      embed screenshot, 'image/png'
    end
  #browser.windows.each {|w| w.close rescue nil} if(browser.windows > 1)
  ensure
    #@browser.quit
    loggedIn = TestRun.loggedIn
    # (TestRun.browser.windows.count..2).each { |windowNo|      
    #   TestRun.log.info "Closing Window: #{TestRun.browser.windows[(windowNo-1)].title}"
    #   TestRun.browser.windows[(windowNo-1)].close 
    # }  
    TestRun.browser.windows.count.downto(2) do |windowNo|
      TestRun.log.info "Current Window count = #{windowNo}"
      TestRun.log.info "Closing Window: #{TestRun.browser.windows[(windowNo-1)].title}"
      TestRun.browser.windows[(windowNo-1)].close
    end

    # if isTopMenuButtonPresent?("AccountManagement") #Added by Alex 
    #   selectFromTopMenu("AccountManagement")
    #   waitForExpectedPageTitle("KDS-Account Management")
    # end #Added by Alex 
    #binding.pry
  end
end

at_exit do
  TestRun.browser.quit
end

#Before('@login') do
  #@browser.goto 'http://10.39.64.163:8080/kds/loginAction.action'
#  @browser.goto 'http://10.39.64.111:8080/kds/loginAction.action'
#  @browser.text_field(:id => "userName").set "admin"
#  @browser.text_field(:id=>"password").set "admin123"
#  @browser.image(:id=>"btnSubmit").click
#  Watir::Wait.until { @browser.window.title.eql?"KDS-Account Management"}
#  Watir::Wait.until { @browser.ready_state.eql?"complete"}
#end

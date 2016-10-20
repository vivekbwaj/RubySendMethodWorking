# require 'watir/winClicker'
# require 'watir/contrib/enabled_popup'
require 'rubygems'
require "watir-webdriver/wait"
require 'colorize'

module ReusableMethods
  module_function

    def initialize 
        @pageObjects = YAML.load_file("features/support/data/pageObjects.yml")
        @actionMaps = YAML.load_file("features/support/data/actionMaps.yml")    
    end

    def theBrowser
      #return  $browser      
      TestRun.browser
    end

    def LoadURL(url)
      puts "#{theBrowser.title}"
      theBrowser.goto url
    end


    def enterText(elementName,textContent,pageKey)
          
      initialize
      TestRun.log.info "entering '#{elementName}' "
      locator=eval(@pageObjects[pageKey][elementName]["Selector"])
      theBrowser.text_field(locator).send_keys textContent
      #return element  
    end
    
    def clickOn(elementName,pageKey)
      initialize
      TestRun.log.info "entering '#{elementName}' "
      locator=eval(@pageObjects[pageKey][elementName]["Selector"])
      #theBrowser.button(locator).click
      theBrowser.button(locator).click
      sleep 5
      puts theBrowser.text_field(:id=>'phSearchInput').present?
    end

    def formatToPageKey(pageKey)
      pageKey.gsub(/[^A-Za-z0-9]+/, "")
    end

    def onExpectedPage?(pageKey)
      initialize
      pageKey = formatToPageKey(pageKey)
      raise "Page Key '#{pageKey}' is not defined" if(@pageObjects[pageKey].nil?)
      raise "Meta section is missing for '#{pageKey}'" if(@pageObjects[pageKey]["Meta"].nil?)
      raise "Page Title is missing for '#{pageKey}'" if(@pageObjects[pageKey]["Meta"]["PageTitle"].nil?)
      expectedPageTitle = @pageObjects[pageKey]["Meta"]["PageTitle"]
      return (currentWindowTitle.eql? expectedPageTitle)
    end

    def highlight(element,pageTitle)
        theElement(element,pageTitle).flash
    end
   
   def waitForBrowserLoading
      sleep(3) # it will take a while for popup to display 
      tries = 20
      begin
        useMostRecentWindow
        # theBrowser.windows.last.use
        TestRun.log.info "Browser #{theBrowser.title} is loaded"
      rescue
        TestRun.log.info "Rescue from read title error, retry in 15s"
        tries -= 1
        if tries > 0
          sleep 15
          TestRun.log.info "Retry read title"
          retry
        else
          TestRun.log.info "Browser is not responding"
          raise "Browser cannot be loaded"
        end
      end
    end

    # DO NOT DELETE THIS 
    # def waitForBrowserLoading
    #   tries = 20
    #   begin
    #     # TestRun.log.info theBrowser.title
    #     return theBrowser.title
    #     TestRun.log.info "Browser loaded"
    #   rescue
    #     TestRun.log.info "Rescue from read title error"
    #     tries -= 1
    #     if tries > 0
    #       sleep 15
    #       TestRun.log.info "Retry read title"
    #       retry
    #     else
    #       TestRun.log.info "Browser is not responding"
    #       raise "Browser cannot be loaded"
    #     end
    #   end
    # end


    def currentWindowTitle
      begin
        return theBrowser.title
      rescue
        return nil
      end
    end

    def useMostRecentWindow
      #TestRun.log.info "Search for most recent window"
      return if(currentWindowTitle.eql? theBrowser.windows.last.title)
      TestRun.log.info "Window count #{theBrowser.windows.count}. Switching from #{currentWindowTitle} to #{theBrowser.windows.last.title}"
      theBrowser.windows.last.use  
      return  theBrowser.window
    end

    def selectFromTopMenu(menuItem)
      theElement(menuItem, "TopMenu").click
    end
    
    def selectFromSideMenu(menuItem)
      theElement(menuItem, "SideMenu").click
    end

    def waitForPopUpWindowToClose(timeout = 900)
      currentWindowCount = theBrowser.windows.count
      TestRun.log.info "Current Window count = #{currentWindowCount}"
      # binding.pry if currentWindowCount == 1
      raise "No popup windows found, only 1 window '#{useMostRecentWindow.title}' is visible" if currentWindowCount == 1
      # binding.pry
      theBrowser.wait_while(timeout) { theBrowser.windows.count >= currentWindowCount }
      # useMostRecentWindow
    end

    def waitForPopUpWindowToOpen(timeout = 600)
      currentWindowCount = theBrowser.windows.count
      TestRun.log.info "Current Window count = #{currentWindowCount}"
      # binding.pry
      theBrowser.wait_until(timeout) { theBrowser.windows.count >= 2 }
      TestRun.log.info "Current Window title = #{theBrowser.title}"
    end    

    def waitWhilePopupDisplayed(windowsCount)
       theBrowser.wait_while { theBrowser.windows.count == windowsCount }
       useMostRecentWindow
    end

    def popupWindowShouldBeClose(popupWindow)
       # waitForPopUpWindowToClose(120)
       theBrowser.wait_until { theBrowser.windows.count == 1 }
       useMostRecentWindow
       expect(theBrowser.title.include?(popupWindow)).to be false       
     
    end

    def progressMessagePresented(messageElementID)
      raise "Progress Message is not displayed" if(!theElement(messageElementID).present?)
      theBrowser.wait_until { theElement(messageElementID).present? }
      sleep(180)
      theElement(messageElementID).wait_while_present(timeout = 300)
    end

    def waitForExpectedPageTitle(expectedPageTitle)     
      theBrowser.wait(timeout = 400)
      useMostRecentWindow
      return if(currentWindowTitle.eql? expectedPageTitle)      
      TestRun.log.info "Actual title #{currentWindowTitle}, wait for #{expectedPageTitle}"
      theBrowser.wait_until  { currentWindowTitle.eql? expectedPageTitle } 
      raise "=== Wrong page ===" if currentWindowTitle != expectedPageTitle 
      TestRun.log.info "On the page #{currentWindowTitle}"  
      
       # returnMessage="Page title located"
       # title=currentWindowTitle
       # puts "starting nowww  with title #{title}"
       # counter = 0

       # for i in 0..50

       #  if i.eql? 50
       #   returnMessage="Page title not found in #{i} seconds"
       #    break

       #  elseif currentWindowTitle.eql? expectedPageTitle
       #    puts "time take to load page:#{title} is #{i} "
       #     break

       #  else
       #   sleep 1
       #   counter=i
       #   title=expectedPageTitle
       #   puts "hi"
       #  end
       # end
       # puts "time take to load page:#{title} is #{counter} "

    end

    def waitForExpectedPageElement(element)
      theBrowser.wait_until(timeout = 300) {theElement(element).present?}

      return theElement(element)
    end

    def isWindowPresent?(pageTitle)
      theBrowser.windows.each { |window| return true if window.title.eql? pageTitle }
      return false
    end

    def closeWindow(pageTitle)
      theBrowser.window(:title => pageTitle).close
      # theBrowser.wait_while(timeout) { theBrowser.title == pageTitle}
    end

    def closePopupWindow
      theBrowser.windows.last.close
    end

    def isImageElementEnabled?(element)
      imageSrc = theElement(element).src
      if imageSrc.include? "disable"
        TestRun.log.info "#{element} is disabled"
        return false
      elsif imageSrc.include? "enable" 
        TestRun.log.info "#{element} is enabled"
        return true
      else
        TestRun.log.info "#{element} is enabled"
        return true
      end
    end

    def isImageElementDisabled?(element)
      imageSrc = theElement(element).src
      if imageSrc.include? "disable"
        TestRun.log.info "#{element} is disabled"
        return true
      elsif imageSrc.include? "enable" 
        TestRun.log.info "#{element} is enabled"
        return false
      else
        TestRun.log.info "#{element} is enabled"
        return false
      end
    end

    def theElement(element, pageTitle = nil)
      initialize    
      useMostRecentWindow
      pageTitle = currentWindowTitle if pageTitle.nil?
      pageKey = formatToPageKey(pageTitle)  
      #TestRun.log.info "PAGE KEY is #{pageKey}"	  
      #raise "We are not on the correct page. Actual #{currentWindowTitle}, Expected #{pageTitle}" unless onExpectedPage?(pageKey)
      # Remove space from the control name
      element = element.gsub(' ', '')   
	  # binding.pry
      elementType = @pageObjects[pageKey][element]["Type"]  
      raise "#{element} is not defined for #{pageKey} page" if elementType.nil? 
        
        
      anchorPointName = @pageObjects[pageKey][element]["AnchorPoint"]      
      
      if anchorPointName.nil?
        anchorPoint = theBrowser
      else
        TestRun.log.info "Looking for Anchor Point #{anchorPoint} element"
        anchorPoint = theElement(anchorPointName)
        raise "Unable to find the anchor point '#{anchorPointName}' for element '#{element}' on #{pageKey} page key" if elementType.nil? 
      end
      TestRun.log.info "Element definition found. #{elementType} #{@pageObjects[pageKey][element]["Selector"]} in '#{pageKey}' page key"

      selector = eval(@pageObjects[pageKey][element]["Selector"]) 
      # the below statement clicks
      # anchorPoint.send("#{elementType}", selector).click
      return anchorPoint.send("#{elementType}", selector)
    end

    # wip
    def selectElement(type, selector, anchorPoint = nil)
      if anchorPoint.nil?
        anchorPointName = theBrowser
      else
        TestRun.log.info "Looking for Anchor Point #{anchorPoint} element"
      end
    end

    # guoch branch - comment out
    # def onElement(elementName, action, value = nil, pageTitle = nil)    
    #   element = theElement(elementName, pageTitle)    
    #   action = @actionMaps[action]
    #   @log.info "'#{action}' on #{elementName} #{value}"
    #   value.nil? ? element.send(action) : element.send(action, value)
    #   return element    
    # end 

    def selectFromToolbarMenu(menuName, option)
      theElement(menuName).hover
      TestRun.log.info "Hovers on #{menuName}"
      theElement(option).click
      TestRun.log.info "Clicks on #{option}"
    end

    def selectFromMenuByText(menuNameElement, optionListElement, optionText)
      theElement(menuNameElement).click
      TestRun.log.info "Clicks on #{menuNameElement}"
      theElement(optionListElement).link(:text, optionText).click
    end

    def onElement(elementName, action, value = nil, pageTitle = nil)    
      element = theElement(elementName, pageTitle)    
      action = @actionMaps[action]
      TestRun.log.info "'#{action}' on #{elementName} #{value}"
      value.nil? ? element.send(action) : element.send(action, value)
      return element    
    end 

    def refreshBrowser
      sleep(3)
      theBrowser.send_keys [:control, :f5]
      sleep(3)
    end

    def closeAlertIfPresent(alert_message = nil)
      useMostRecentWindow 
      if (TestRun.browser.alert.exists?) 
        msg_received = TestRun.browser.alert.text
        TestRun.log.error "Unexpected error message. Actual '#{msg_received}' , Expected '#{alert_message}'" if !alert_message.nil? && !alert_message.eql?(msg_received)
        TestRun.browser.alert.close
        TestRun.log.warn "Alert '#{msg_received}' was closed."
      end
    end

  
end

World(ReusableMethods)
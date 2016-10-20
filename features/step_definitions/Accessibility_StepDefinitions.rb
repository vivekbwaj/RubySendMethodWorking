require 'chronic'
require 'time'
require 'colorize'
require 'win32ole'


$sourceURL="view-source:https://dhhsvic.service-now.com/ramp/"
$siteURL="https://dhhsvic.service-now.com/ramp/"

Given(/^the user has logged into "([^"]*)" website as "([^"]*)"$/) do |environment, uName|

  if isElementPresent("Login","Portal",10) then
	    onElement("Username", "set", "uxcps.vb", "Portal")
      onElement("Password", "set", "Welcome1", "Portal")
      theElement("Login", "Portal").flash
      theElement("Login", "Portal").click
      $loggedIn = true

      if isElementPresent("Logout","Portal",10) then
        puts "Logged in successfully"
      else
        raise "Clicked on login button but didn't land on expected page"
      end
  else
    raise "Couldn't log in"
  end

end


Given(/^the user is on page with "([^"]*)" and "([^"]*)" and "([^"]*)"$/) do |title, url, locator|
 
  LoadURL("#{$siteURL}"+url)

   if isElementPresent(locator,"Portal",10) then
        puts "Page with title #{title} loaded".cyan
        LoadURL("#{$sourceURL}"+url)
        sleep 3
   else
      raise "Couldn't load the desired page"
   
   end

end

When(/^user fetches the sourceCode and validates it$/) do

    theBrowser.send_keys [:control, 'a'], :backspace
    sleep 2
    theBrowser.send_keys [:control, 'c'], :backspace
    sleep 2
    LoadURL("http://squizlabs.github.io/HTML_CodeSniffer/")
        if isElementPresent("SnifferPageIdentifier","Portal",10) then
              theBrowser.div(:id=>"code-overlay").click
              theBrowser.send_keys [:control, 'v'], :backspace
              inputs = theBrowser.elements(:class=>"radio-gen")
              inputs.each do |radios|
                text=radios.parent.input(:type=>"radio").attribute_value("value")
                 if text=="WCAG2AA"
                   radios.click
                   #sleep 2
                 end     
              end 

                theElement("CodeSniffer","Portal").click
                if isElementPresent("Results","Portal",10) then
                  puts "Results table generated".yellow
                  theElement("Results","Portal").flash
                  theBrowser.span(:class=>"result-count result-count-notices").click
                  #sleep 2
                end
        else
           raise "HTMLCodeSniffer page didn't load"

        end
end

Then(/^the results are written to the excel file in sheet "([^"]*)"$/) do |sheetName|
    n=w=e=0
       notices = Array.new
       warnings = Array.new
       errors = Array.new

          errMsg = theBrowser.elements(:class=>"messageText")
          
          errMsg.each do |allErrors|

            case allErrors.strong.text

            when "Notice:"
                    n+=1
                    notices << allErrors.text
            when "Error:"
              e+=1
              errors << allErrors.text
            when "Warning:"
              w+=1
              warnings << allErrors.text
            else 
              puts "Invalid messageText"
            end            
            #puts allErrors.strong.text.red
            #puts allErrors.text.red 
          end 
          puts "#{e} Errors  #{w} Warnings  #{n} Notices"

          puts "Errors are :"
          puts "#{errors}"

          puts "Notices are :"
          puts "#{notices}"

          puts "Warnings are :"
          puts "#{warnings}"

          ##########excel###############
             n_excel=e_excel=w_excel=2

          excel = WIN32OLE.new('Excel.Application')
        excel.visible = true #true means that the excel will be visible , false= excel runs in background
        workbook = excel.workbooks.open('H:\AccessibilityAutomation\Output_File.xls')
        worksheet = workbook.worksheets("#{sheetName}")
        worksheet.Activate

        errors.each do |err|
         worksheet.Range("A#{e_excel}").value=err
         e_excel+=1
        end

        warnings.each do |warn|
         worksheet.Range("B#{w_excel}").value=warn
         w_excel+=1
        end

        notices.each do |note|
         worksheet.Range("C#{n_excel}").value=note
         n_excel+=1
        end


        workbook.saved = true #Setting it to True is a simple way of preventing the "Do you wish to save..." dialog appearing when Excel is closed
        workbook.Save
        excel.ActiveWorkbook.Close(0)
        excel.Quit()
end

When(/^user logs out$/) do

  LoadURL("https://dhhsvic.service-now.com/ramp/")

    if isElementPresent("Logout","Portal",10) then
         puts "Back to landing page, will logout now"
         theElement("Logout","Portal").flash
         theElement("Logout","Portal").click
      else
        raise "Incorrect page, logout link not found"
      end
end
# require 'watir/winClicker'
# require 'watir/contrib/enabled_popup'
require 'rubygems'
require 'colorize'



 ########################################################
def isElementPresent(elementIs,pageIs,timeLimit)
   found=false
   timer=0
    
    for i in 1..timeLimit
      sleep 1
      timer+=1
        begin     	
          if theElement(elementIs, pageIs).present? then
             found=true
            theElement(elementIs, pageIs).flash
             break
          end
         rescue
         end
     end

 puts "Search time is: #{timer} seconds"
 return found
end

###########################################################
def waitForPageTitleToAppear(title,timeLimit)
  found=false
   timer=0
    
    for i in 1..timeLimit
      sleep 1
      timer+=1
        begin       
          if theBrowser.title==title then
             found=true
             break
          end
         rescue
         end
     end

 puts "Waited for #{timer} seconds to page with <#{title}> title to load"
 return found
end
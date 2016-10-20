require 'chronic'
require 'time'
require 'colorize'


def initializeYaml

	    @pageObjects = YAML.load_file("features/support/data/pageObjects.yml")
        @actionMaps = YAML.load_file("features/support/data/actionMaps.yml")    
end


Given(/^i am testing send method$/) do
	
	highlight("TextfieldUname","Portal")
    enterTextInField("TextfieldUname","Portal","BVDBKJHD")
    sleep 2
end


def returnElement(elementIs,pageKeyIs)
 initializeYaml

   elementType = @pageObjects[pageKeyIs][elementIs]["Type"] 
   locatorType = eval(@pageObjects[pageKeyIs][elementIs]["Selector"]) 

   return theBrowser.send("#{elementType}", locatorType)

end

def enterTextInField(elementIs,pageKeyIs,textIs)
  
   element=returnElement(elementIs,pageKeyIs)
   element.send_keys textIs

end

def highlight(elementIs,pageKeyIs)
	element=returnElement(elementIs,pageKeyIs)
	element.flash
end


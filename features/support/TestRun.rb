

module TestRun

	def self.baseurl
		$baseurl
	end

	def self.browser
		$browser
	end

	def self.loggedIn
		$loggedIn
	end

	def self.envPrefix
		$envPrefix
	end

	def self.testData
		$testData
	end

	def self.log
		$log
	end

	def self.timestamp
		$timestamp
	end
 end

 World(TestRun)
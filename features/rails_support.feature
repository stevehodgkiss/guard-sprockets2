Feature: Rails Support

	Background:
		Given I setup the example rails app for testing
		And I clean the generated assets
	
	Scenario: Compiling assets
		When I run `guard` interactively
		And I wait 5 seconds
		And I stop the process
		Then the output should contain "Compiling assets"
		And the hello asset should be compiled
	
	Scenario: Re-compiling assets
		When I run `guard` interactively
		And I wait 5 seconds
		And a file named "app/assets/javascripts/goodbye.coffee" with:
			"""
      console.log 'Goodbye'
      """
		And I wait 5 seconds
		And I stop the process
		Then the output should contain "Compiling assets"
		And the hello asset should be compiled
		And the goodbye asset should be compiled
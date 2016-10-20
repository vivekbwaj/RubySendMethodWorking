Feature: Test WCAG 2.0 requirements

Background: 
	

 Scenario Outline: Check all pages for "AA" compliance
    Given the user has logged into "Test" website as "Vivek"
 	And the user is on page with "<title>" and "<pageSourceURL>" and "<locator>"
    When user fetches the sourceCode and validates it
    Then the results are written to the excel file in sheet "<title>"
    And user logs out

Examples:
|title|pageSourceURL|locator|
|RAMP - Home|home.do|WelcomePage|
|Make a new referral|new-referral|NewReferral|
|New Referral iFrame|u_ramp_case.do?sys_id=-1&sysparm_stack=u_ramp_case_list.do&sysparm_clear_stack=yes&sysparm_nameofstack=77484a084f2e26009135cf401310c706|NewReferralFrame|
|List my draft referrals|list-referrals|ListReferral|
|List my draft referrals iFrame|u_ramp_case_list.do?sysparm_query=u_status%3D1&sysparm_view=%23&sysparm_clear_stack=yes&sysparm_nameofstack=24e53e044f6e26009135cf401310c76c&sysparm_first_row=1|ListReferralFrame|


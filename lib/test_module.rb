require './HomeAway_module.rb'
require 'mechanize'
include HomeAwayModule

username = "my_awesome@email.com"
password = "123456"
############################################################################
# For test purpose, we simulate the login process (to get cookies)
############################################################################
login_url = "https://cas.homeaway.com/auth/homeaway/login?service=https%3A%2F%2Fwww.homeaway.com%2Fhaod%2Fauth%2Fsignin.html"
agent = Mechanize.new
agent.verify_mode= OpenSSL::SSL::VERIFY_NONE
#agent.log = Logger.new(STDOUT)


# Get the login page
page = agent.get(login_url)


# Get the flowKey needed for the log in process
noko = Nokogiri::HTML(page.body)
flowKey = noko.at_xpath("//input[@name='flowKey']")['value']


# Get the form from this page using its ID parameter
form = page.form_with(:id => 'login-form')

# Fill all the fields (even hidden ones)
form.username = username
form.password = password
form.flowKey = flowKey
form.devicePrint = "Mozilla",   # /!\ Whenever you change the device print, the platform will ask you to log in using double auth. /!\
form._eventId = "submit"
form.locale = "en_US"

# Submit the form
page = form.submit


puts "Current page : #{page.title.gsub("\n",'')} | URL : #{page.uri.to_s}"
puts "-----------------------------------"


# If the double Auth is required (we are not redirected to the dashboard yet)
if !page.title.include? "Dashboard"
  
  # Get the form from this page using its class parameter
  form = page.form_with(:name => 'fm1')
  
  # Choose the number and the method to receive the code for double AUTH
  # Here the phone number 2 will receive the SMS code
  form.radiobutton_with(:value => /2/).check
  form.radiobutton_with(:value => /SMS/).check
  
  # Submit the form
  page = form.submit
  
  puts "Current page : #{page.title} | URL : #{page.uri.to_s}"
  puts "-----------------------------------"
  
  
  # Ask the user the received SMS code
  puts "Enter the code received by SMS"
  code_SMS = gets
  puts "Thanks !"

  # Get the form from this page using its class parameter
  form = page.form_with(:name => 'fm1')
  
  # Fill all the fields (even hidden ones)
  form.code = code_SMS.to_i
  
  # Submit the form
  page = form.submit
  
  puts "Current page : #{page.title} | URL : #{page.uri.to_s}"
  puts "-----------------------------------"
  
end



################################################################################
# Retrieve all the listings
################################################################################
all_listings = Array.new
all_listings = get_all_listings( :cookie_jar => agent.cookie_jar )



# For test purpose choose the first listing
listingRef  = all_listings[0][:id]
druidId     = all_listings[0][:druid]


# Get all reservations made for the first listing between 2015-01-01 and 2015-12-31
all_reservations = get_all_reservations( 
                                          :cookie_jar => agent.cookie_jar,
                                          :listingRef => listingRef,
                                          :druidId    => druidId,
                                          :start_date => "2015-01-01",
                                          :end_date   => "2015-12-31",
                                        )


all_reservations.each do |reservation|
  puts reservation
  puts "~~~~~~~~~~~~~~~~~~~~~~"
end



################################################################################
# We can now use the function to update our calendar
################################################################################
reservationID = create_reservation( 
                                    :cookie_jar => agent.cookie_jar, 
                                    :druidId    => druidId,
                                    :listingRef => listingRef,
                                    :start_date => "2015-09-24",
                                    :end_date   => "2015-09-26",
                                    :status     => "RESERVE"
                                  )

puts "-----------------------------------"

update_reservation( 
                    :cookie_jar     => agent.cookie_jar, 
                    :reservationID  => reservationID,
                    :druidId        => druidId,
                    :listingRef     => listingRef,
                    :start_date     => "2015-09-24",
                    :end_date       => "2015-09-26",
                    :status         => "HOLD"
                  )

puts "-----------------------------------"

delete_reservation( 
                    :cookie_jar     => agent.cookie_jar, 
                    :reservationID  => reservationID
                  )

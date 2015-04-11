module HomeAwayModule

  # Create a reservation with a status according to its dates.
  #
  # @cookie_jar Required to be cookie from Mechanize session
  # @raise [FalseClass] Error raised when supplied arguments are not valid and return.
  # @return [String] The reservation ID created
  # @overload create_reservation(args = {})
  #   @args cookie_jar [Mechanize::CookieJar] The session cookie from a previous login.
  #   @args druidId [String] The druid ID of the calendar.
  #   @args listingRef [String] The druid ID of the calendar.
  #   @args start_date [String] The start date of the update.
  #   @args end_date [String] The end date of the update.
  #   @args status [String] Must be "RESERVE", "HOLD" or "UNAVAILABLE".
  def create_reservation( args = {} )
    
    # Variables declarations
    cookie_jar      = args[:cookie_jar]       || nil
    druidId         = args[:druidId]          || nil
    listingRef      = args[:listingRef]       || nil
    start_date      = args[:start_date]       || DateTime.now.strftime("%F")
    end_date        = args[:end_date]         || DateTime.now.strftime("%F")
    status          = args[:status]           || "RESERVE"
    
    
    ############################################################################
    # Validate the variables
    ############################################################################    
    valid = validate_args(  :cookie_jar     => cookie_jar,
                            :reservationID  => false,
                            :druidId        => druidId,
                            :listingRef     => listingRef,
                            :start_date     => start_date,
                            :end_date       => end_date,
                            :status         => status
                          )
                  
    if valid == false
      return false
    end
    
    
    # Summarize the creation asked...
    puts "Create a reservation from #{start_date} to #{end_date} with the status #{status}."
    puts "-----------------------------------"




    ############################################################################
    # Start the creation process for the reservation
    ############################################################################
    data = create_data( nil, druidId, listingRef, start_date, end_date, status )
    headers = create_headers(cookie_jar)
    http = create_http


    # Send the JSON request to create a reservation
    res = http.start { |req|
      req.send_request('POST', "/haoi/reservations/create?locale=en_US&_restfully=true&_=#{Time.now.to_i}", data, headers)
    }
    
    reservation_reponse = JSON.parse(res.body)

    # Return the reservationID or -1 in case of failure
    if res.kind_of? Net::HTTPSuccess
      reservationID = reservation_reponse["id"]
      puts "The reservation has been made. Reservation ID : #{reservationID}"
      return reservationID
    else
      reservation_reponse["error"].each{|key, hash| puts "#{key} : #{hash}" }
      return false
    end
    
  end
  
  
################################################################################
################################################################################
  
  # Update a reservation with a status according to its dates.
  #
  # @cookie_jar Required to be cookie from Mechanize session
  # @raise [FalseClass] Error raised when supplied arguments are not valid and return.
  # @return [String] The reservation ID updated
  # @overload create_reservation(args = {})
  #   @args cookie_jar [Mechanize::CookieJar] The session cookie from a previous login.
  #   @args reservationID [String] The reservation ID.
  #   @args druidId [String] The druid ID of the calendar.
  #   @args listingRef [String] The druid ID of the calendar.
  #   @args start_date [String] The start date of the update.
  #   @args end_date [String] The end date of the update.
  #   @args status [String] Must be "RESERVE", "HOLD" or "UNAVAILABLE".
  def update_reservation( args = {} )
    
    # Variables declarations
    cookie_jar      = args[:cookie_jar]       || nil
    reservationID   = args[:reservationID]    || nil
    druidId         = args[:druidId]          || nil
    listingRef      = args[:listingRef]       || nil
    start_date      = args[:start_date]       || DateTime.now.strftime("%F")
    end_date        = args[:end_date]         || DateTime.now.strftime("%F")
    status          = args[:status]           || "RESERVE"
    
    
    ############################################################################
    # Validate the variables
    ############################################################################    
    valid = validate_args(  :cookie_jar     => cookie_jar,
                            :reservationID  => reservationID,
                            :druidId        => druidId,
                            :listingRef     => listingRef,
                            :start_date     => start_date,
                            :end_date       => end_date,
                            :status         => status
                          )

    if valid == false
      return false
    end
    
    
    # Summarize the update asked...
    puts "Update the reservation (#{reservationID}) with dates from #{start_date} to #{end_date} and the status #{status}."
    puts "-----------------------------------"




    ############################################################################
    # Start the update process for the reservation
    ############################################################################
    data = create_data( reservationID, druidId, listingRef, start_date, end_date, status )
    headers = create_headers(cookie_jar)
    http = create_http


    # Send the request to update the calendar
    res = http.start { |req|
      req.send_request('PUT', "/haoi/reservations/update?reservationId=#{reservationID}&_restfully=true&_=#{Time.now.to_i}", data, headers)
    }
    
    reservation_reponse = JSON.parse(res.body)

    # Return the reservationID or -1 in case of failure
    if res.kind_of? Net::HTTPSuccess
      puts "The reservation has been updated. Reservation ID : #{reservationID}"
      return reservationID
    else
      reservation_reponse["error"].each{|key, hash| puts "#{key} : #{hash}" }
      return false
    end
    
  end
  
  
################################################################################
################################################################################
  
  # Delete a reservation.
  #
  # @cookie_jar Required to be cookie from Mechanize session
  # @raise [FalseClass] Error raised when supplied arguments are not valid and return.
  # @return [TrueClass] Success
  # @overload create_reservation(args = {})
  #   @args cookie_jar [Mechanize::CookieJar] The session cookie from a previous login.
  #   @args reservationID [String] The reservation ID.
  def delete_reservation( args = {} )
    
    # Variables declarations
    cookie_jar      = args[:cookie_jar]       || nil
    reservationID   = args[:reservationID]    || nil
    
    
    ############################################################################
    # Validate the variables
    ############################################################################    
    valid = validate_args(  :cookie_jar     => cookie_jar,
                            :reservationID  => reservationID,
                            :druidId        => false,
                            :listingRef     => false,
                            :start_date     => DateTime.now.strftime("%F"),
                            :end_date       => DateTime.now.strftime("%F"),
                            :status         => "RESERVE"
                          )

    if valid == false
      return false
    end
    
    
    # Summarize the request asked...
    puts "Delete the reservation (#{reservationID})."
    puts "-----------------------------------"




    ############################################################################
    # Start the delete process for the reservation
    ############################################################################
    data = {}.to_json
    headers = create_headers(cookie_jar)
    http = create_http


    # Send the request to delete the reservation
    res = http.start { |req|
      req.send_request('DELETE', "/haoi/reservations/cancel?reservationId=#{reservationID}&_restfully=true&_=#{Time.now.to_i}", data, headers)
    }
    
    reservation_reponse = JSON.parse(res.body)

    # Return the reservationID or -1 in case of failure
    if res.kind_of? Net::HTTPSuccess
      puts "The reservation has been deleted. Reservation ID : #{reservationID}"
      return true
    else
      reservation_reponse["error"].each{|key, hash| puts "#{key} : #{hash}" }
      return false
    end
    
  end
   
  
################################################################################
################################################################################
  
  # Get all listings from HomeAway.
  #
  # @cookie_jar Required to be cookie from Mechanize session
  # @raise [FalseClass] Error raised when supplied arguments are not valid and return.
  # @return [Array] Array of Hash containing informations on every list
  # @overload create_reservation(args = {})
  #   @args cookie_jar [Mechanize::CookieJar] The session cookie from a previous login.
  def get_all_listings( args = {} )
    
    # Variables declarations
    cookie_jar      = args[:cookie_jar]       || nil
    
    ############################################################################
    # Validate the variables
    ############################################################################    
    
    # Need session cookie and must come from Mechanize to continue
    if cookie_jar.nil? or cookie_jar.class != Mechanize::CookieJar
      puts "You need to pass session cookie (from Mechanize) to continue."
      return false
    end
    
    
    
    # Create a new agent to go to the listing URL
    agent = Mechanize.new
    agent.cookie_jar = cookie_jar
    all_listings = Array.new
    
    page = agent.get("https://www.homeaway.com/lm/location.html")
    
    
    # For each list
    page.links.each do |link|
      
      # Get listing ID
      listing_id = page.links[0].href.to_s.sub(/.*lm\/(.*?)\/.*/) { $1 }
      # Get image URL
      image_url = agent.get("https://www.homeaway.com/lm/#{listing_id}/photos.html").search("#photoDisplayed").to_s.gsub("\n",'').sub(/.*url\('(.*?)'\).*/) { $1 }
      # Get druid ID
      noko = Nokogiri::HTML(agent.get("https://www.homeaway.com/haoi/#{listing_id}/calendars/display.html#year").body)
    
      # Get druidId from page body (inside a script with name : propertyDruid)
      druidId = ''
      noko.css("script").each do |script|
        # Find the script that contains the variable needed
        if script.children.to_s.include? "propertyDruid"
          script.children.to_s.sub(/.*propertyDruid = '(.*)'.*/) { druidId = $1 }
        end
      end
      
      hash = { :id => listing_id, :name => link.text.split('-')[1], :link => "https://www.homeaway.com+#{link.href}", :image => image_url, :druid => druidId}
      
      all_listings.push(hash)
    end
    
    return all_listings
    
  end


################################################################################
################################################################################
  
  # Get all reservations from a listing.
  #
  # @cookie_jar Required to be cookie from Mechanize session
  # @raise [FalseClass] Error raised when supplied arguments are not valid and return.
  # @return [Array] Array of Hash containing informations on every reservations
  # @overload create_reservation(args = {})
  #   @args cookie_jar [Mechanize::CookieJar] The session cookie from a previous login.
  #   @args listingRef [String] The listing ID.
  #   @args druidId [String] The druid ID of the calendar.
  #   @args start_date [String] The start date of the update.
  #   @args end_date [String] The end date of the update.
  def get_all_reservations( args = {} )
    
    # Variables declarations
    cookie_jar      = args[:cookie_jar]       || nil
    listingRef      = args[:listingRef]       || nil
    druidId         = args[:druidId]          || nil
    start_date      = args[:start_date]       || DateTime.now.strftime("%F")
    end_date        = args[:end_date]         || DateTime.now.strftime("%F")
    
    
    ############################################################################
    # Validate the variables
    ############################################################################    
    valid = validate_args(  :cookie_jar     => cookie_jar,
                            :reservationID  => false,
                            :druidId        => druidId,
                            :listingRef     => listingRef,
                            :start_date     => DateTime.now.strftime("%F"),
                            :end_date       => DateTime.now.strftime("%F"),
                            :status         => "RESERVE"
                          )

    if valid == false
      return false
    end
    

    
    ############################################################################
    # Get all reservations
    ############################################################################
    
    # Create the data and headers for the JSON request
    data = {}.to_json
    headers = create_headers(cookie_jar)
    http = create_http


    # Send the request to get all reservations
    res = http.start { |req|
      req.send_request('GET', "/gd/proxies/conversations/inbox?_restfully=true&page=1&pageSize=365&locale=en_US&sort=stayDate&sortOrder=asc&druid=#{druidId}&reservations=true&status=RESERVATION", data, headers)
    }
    
    
    request_reponse = JSON.parse(res.body)
    all_reservations = Array.new
    
    # Once we have a list of all reservations
    request_reponse['conversations'].each do |reservation|
      
      # We need to get the reservation link (and notes) from a JSON call to retrieve all the informations needed
      res = http.start { |req|
        req.send_request('GET', "/gd/proxies/conversations/conversation?conversationId=#{reservation['id']}&_restfully=true", data, headers)
      }
      
      reservation_link_reponse = JSON.parse(res.body)
      reservation_link = reservation_link_reponse['reservation']['reservationLink']
      reservation_notes = reservation_link_reponse['reservation']['comments']
      reservationID = reservation_link.to_s.sub(/\/reservations\/(.*)\/(.*)/) { $2 }
      
      
      # Once we have the reservation link we can request for all informations (needed for tax and rental amount).
      # This JSON request is done by HomeAway to fill the reservation page with all informations needed by the template
      res = http.start { |req|
        req.send_request('GET', "/gd/proxies/ecomQuote/getTemplate?_restfully=true&site=HOMEAWAY_US&locale=en_US&externalRefLink=#{reservation_link}&unitLink=#{reservation['property']['unitLink']}&checkInDate=#{reservation['stayStartDate']}&checkOutDate=#{reservation['stayEndDate']}", data, headers)
      }
      
      # Now we have all informations that we can ask for the reservation
      reservation_infos = JSON.parse(res.body)
      
      # Check the start_date and end_date
      if ( reservation_infos['checkinDate'] >= start_date ) and ( reservation_infos['checkoutDate'] <= end_date )
        
        guessName   = reservation_infos['traveler']['firstName'] || "Unknown"
        guessEmail  = reservation_infos['traveler']['email']     || "Not provided"
        guessPhone  = reservation_infos['traveler']['phone']     || "Not provided"
        
        hash = { 
          :reservationID  => reservationID,
          :checkinDate    => reservation_infos['checkinDate'],
          :checkoutDate   => reservation_infos['checkoutDate'],
          :guessName      => guessName,
          :guessEmail     => guessEmail,
          :guessPhone     => guessPhone,
          :rentalAmount   => reservation_infos['quoteTotals']['amount'],
          :cleaningFee    => reservation_infos['fees'][1]['amount']['amount'],
          :tax            => reservation_infos['quoteTotals']['totalTax']['amount']['amount'],
          :bookingFee     => reservation_infos['fees'][3]['amount']['amount'],
          :numAdults      => reservation_infos['numAdults'],
          :numChildren    => reservation_infos['numChildren'],
          :notes          => reservation_notes
        }
        
        all_reservations.push(hash)
      end

    end


    # Return the reservationID or -1 in case of failure
    if res.kind_of? Net::HTTPSuccess
      puts "We found #{all_reservations.length} reservations out of #{request_reponse['display']['totalResults']} for the listing ID : #{listingRef}"
      return all_reservations
    else
      request_reponse["error"].each{|key, hash| puts "#{key} : #{hash}" }
      return false
    end
    
  end
  
################################################################################
################################################################################
  
  
  def create_data ( reservationID, druidId, listingRef, start_date, end_date, status )
    data = {  
      "id"            => reservationID,
      "druidId"       => druidId,
      "listingRef"    => listingRef,
      "listingId"     => "",
      "inquiryId"     => "",
      "inquiryId"     => "",
      "numAdults"     => 0,
      "numChildren"   => 0,
      "comments"      => "",
      "source"        => "DASH",
      "status"        => status,
      "paymentStatus" => "NONE",
      "checkinDate"   => start_date,
      "checkoutDate"  => end_date,
      "checkinTime"   => "18:00",
      "checkoutTime"  => "21:00",
      "guest"         => {
        "firstName"     => "",
        "lastName"      => "",
        "emailAddress"  => "",
        "homePhone"     => "",
        "mobilePhone"   => "",
        "faxNumber"     => "",
        "addressLine1"  => "",
        "addressLine2"  => "",
        "city"          => "",
        "state"         => "",
        "country"       => "US",
        "postalCode"    => ""
      }
    }.to_json
    
    return data
  end
  
  
################################################################################
################################################################################
  
  
  def create_headers ( cookie_jar )
    # Get the cookie needed to make the JSON request
    cookie_HA_SESSION = ''
    cookie_jar.each do |value|
      if value.to_s.include? "HA_SESSION"
        cookie_HA_SESSION = value.to_s
      end
    end


    # Create the header with the cookie
    headers = { 
                'Content-Type' => 'application/json',
                'Cookie' => cookie_HA_SESSION
              }
    
    return headers
  end
  
  
################################################################################
################################################################################
  
  
  def create_http
    # Construct the URL for the JSON request
    url = "https://www.homeaway.com"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    return http
  end
  
  
################################################################################
################################################################################
  
  
  def validate_args( args = {} )
    
    cookie_jar      = args[:cookie_jar]
    reservationID   = args[:reservationID]
    druidId         = args[:druidId]
    listingRef      = args[:listingRef]
    start_date      = args[:start_date]
    end_date        = args[:end_date]
    status          = args[:status]
    
    # Need session cookie, druidId, listingRef and reservationID to continue
    if cookie_jar.nil? or druidId.nil? or listingRef.nil? or reservationID.nil?
      puts "You need to pass session cookie (from Mechanize), druidId, listingRef and reservationID to update your HomeAway's calendar."
      return false
    end
    
    # Session cookie must come from Mechanize
    if cookie_jar.class != Mechanize::CookieJar
      puts "You need to pass session cookie from Mechanize (Mechanize::CookieJar) only."
      return false
    end
    
    # The status must be "RESERVE", "HOLD" or "UNAVAILABLE"
    if (status != "RESERVE") and (status != "HOLD") and (status != "UNAVAILABLE") 
      puts "Status (#{status}) must be \"RESERVE\", \"HOLD\" or \"UNAVAILABLE\""
      return false
    end
    
    # Check the start date format
    begin
      Date.parse(start_date)
    rescue ArgumentError
      puts "The start date format (#{start_date}) is wrong. Date must be \"YEAR-MONTH-DAY\"."
      return false
    end
    
    # Check the end date format
    begin
      Date.parse(end_date)
    rescue ArgumentError
      puts "The start date format (#{end_date}) is wrong. Date must be \"YEAR-MONTH-DAY\"."
      return false
    end
    
    # End date must be superior or equal of start date
    if end_date < start_date
      puts "End date (#{end_date}) cannot be before start date (#{start_date})."
      return false
    end
    
    # Date must be superior or equal of today
    if start_date < DateTime.now.strftime("%F")
      puts "Start date (#{start_date}) must be superior or equal of today."
      return false
    end
    
  end
  
end
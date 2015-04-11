# HomeAway Module

Connect to your [HomeAway](http://www.homeaway.com/) account and manage all your listings and reservations.

## Process
The test process connects to your account and retrieved all your listing. Choose the first one and print all reservations for this listing. It will then create, update and delete a reservation.

## Functions
### get_all_listings
Get all listings from your HomeAway account.
Return Array of Hash containing informations on every list

### get_all_reservations
Get all reservations from a listing.
Return Array of Hash containing informations on every reservations

### create_reservation
Create a reservation with a status according to its dates.
Return the reservation ID created

### update_reservation
Update a reservation with a status according to its dates.
Return the reservation ID updated

### delete_reservation
Delete a reservation.
Return true or false

Original App Design Project
===
Checkout the demo of the current progress: https://youtu.be/AouyO6b6K9c
# 

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Application that lets musicians of all skill levels find other musicians to jam with

### App Evaluation
- **Category:** Music / Social
- **Mobile:** Mobile first design, nearly all users would use the mobile app. Uses location, camera, and audio recording.
- **Story:** Allows musicians to find friends to play with and share content. Allows musicians to organize jam sessions wit other user's of the app.
- **Market:** Anybody who plays an instrument, either at a beginner level, intermediate, or advanced.
- **Habit:** Users can look through new potential band mates all day long (algorithm recommends users most likely to match first). They can try out different musicians and share their performance sound bites. Very addicting in the same ways that Tinder is. The average user will likely open this app a few times a day, they would create content as well as consume it.
- **Scope:** The MVP of the app includes matching with nearby musicians, as well as messaging. P2 features include the ability to organize jam sessions whithin the app, and have groupchats for each of those so users don't have to leave the app at all.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can create a new account
- [x] User can login/logout
- [x] Being able to find musicians in your local area
- [x] Being able to post a soundbite 
- [x] Messaging other users (to schedule a meetup)
- [x] Personalized jam buddy suggestions based on location, instrument preferences, and genre preferences.

**Optional Nice-to-have Stories**

- [x] Being able to organize jam sessions inside the app and invite people
- [x] In-app groupchats for events
- [x] Automatic recognition of instruments in a sound bite using CoreML (automatically detecting the instruments in a sound bite prevents users from cheating by forcing them to prove that they can play an instrument before putting it in their profile)
- [x] Optimal location for events (based on least aggregrate travel distance for all invitees)
- [x] Being able to like messages by double-tapping them
- [ ] Users are able to post videos instead of soundbites
- [ ] Being able to follow people and view their feed
- [ ] Experienced musicians can offer paid lessons

### 2. Screen Archetypes

* Login Screen
   * User can login
* Rgistration Screen
   * User can create an account
* Matching screen
   * User can cycle through musician in their local area
   * User can swipe left or right
* Profile Screen
   * User can update location information, profile picture, bio, liked genres, and liked instruments
   * User can record and upload a new sound bite
* Messaging Screen
   * User can view their matches and enter into DMs with them
   * User can sent messages and receive them in real time
   * User can double-tap a message to like it

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Matching Screen
* Profile Screen
* Messaging Screen
* Events screen

**Flow Navigation** (Screen to Screen)

* Login Screen
   * Matching Screen
* Registration Screen
   * Profile Screen
* Matches screen
   * Chat Screen
* Chat Screen
   * User profile
   * Event info
* Events screen
   * Chat screen
   * Event info     
* Event info
   * Location picker
   * Add Invitee
   * Profile screen
* Profile screen
   * Compose bio screen
   * Photo picker screen
   * Add Liked Entity (instrument and genre) screen
   * Record sound bite screen
   * Settings screen

## Wireframes
<img src="https://github.com/rigrergl/fbu-project/blob/main/wireframe_1.jpg" width=600>

## Schema 
### Models
#### User

| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| username    | String      |unique username for user 
| password    | String      |password for user
| latestLatitude    | Number      |last known latitude of user
| latestLongitude   | Number      |last known longitude of user
| instrumentsInRecording  | Array of String  | instruments the user can play (using application standard name)
| profileImage| File        |profile image for user
| recording       | File    | sound file of the user's recording (displayed on user's profile and on user's card)
| bio       | String    | user's bio
| createdAt   | DateTime      |date when user is created (default field)
| updatedAt   | DateTime      |date when user is last updated (default field)

#### Like
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| originUser  | Pointer to User | User that made the like
| destinationUser  | Pointer to User | User that was liked
| createdAt   | DateTime      |date when like is created (default field)
| updatedAt   | DateTime      |date when like is last updated (default field)

#### Match
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| users  | Array of Pointer to User | users in match (length of 2)
| hasConversationStarted  | BOOL | indicates whether the users have started a conversation
| createdAt   | DateTime      |date when like is created (default field)
| updatedAt   | DateTime      |date when like is last updated (default field)

#### UnLike
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| originUser       | Pointer to User |first user in the unlike
| destinationUser       | Pointer to User |second user in the unlike
| createdAt   | DateTime      |date when like is created (default field)
| updatedAt   | DateTime      |date when like is last updated (default field)

#### Event
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| organizer    | Pointer to User |user that created the event
| date    | Date |time the event is going to happen
| location    | String | Name of venue
| venue    | Pointer to FoursquareVenue | venue object of this event
| title    | String | title of the event
| image    | File | image displayed on event card
| invited    |Array of Pointer to User |list of users that were invited to this event
| accepted    |Array of Pointer to User |list of users that accepted the invitation to this event
| createdAt   | DateTime    |date when like is created (default field)
| updatedAt   | DateTime    |date when like is last updated (default field)



#### DirectMessage
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| createdAt   | DateTime    |date when like is created (default field)
| author      | Pointer to User    |user that sent the message
| match | Pointer to Match   |match this message belongs to (null = this is an Event message)
| event | Pointer to Event   |event this message belongs to (null = this is a Match message)
| content     | Strings    |contents of the message
| usersLiked     | Array of User    | users that have liked this message
| likes     | Number    | number of likes in message
| updatedAt   | DateTime    |date when like is last updated (default field)

#### FoursquareVenue
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| createdAt   | DateTime    |date when like is created (default field)
| latitude   | Number    | latitude of the venue
| longitude   | Number    |longitude of the venue
| venueId   | String    | id of venue in Foursquare database
| name   | String    | name of the venue
| eventId   | String    | id of event this venue is associated with
| updatedAt   | DateTime    |date when like is last updated (default field)

#### LikedGenre
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| createdAt   | DateTime    |date when like is created (default field)
| title   | String    | title of genre (using application standard)
| user   | Pointer to User    | user that has liked this genre
| updatedAt   | DateTime    |date when like is last updated (default field)

#### LikedInstrument
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| createdAt   | DateTime    |date when like is created (default field)
| title   | String    | title of instrument (using application standard)
| user   | Pointer to User    | user that has liked this instrument
| updatedAt   | DateTime    |date when like is last updated (default field)


### Networking
## List of Network requests by screen
- Matching Screen
   - (GET) Query all users that fit the logged in user's preferences (and which the logged in user has not already liked). Sort these users by compatibility with current user (liked genres, instruments, location)
   - (POST) new Like from current user to user in card
   - (POST) new UnLike from current user to user in card
- Profile Screen
    - (GET) instuments liked by current user
    - (GET) genres liked by current user
    - (GET) current user's profile image
    - (GET) current user's bio
    - (GET) current user's recording data
    - (PUT) instruments liked by current user
    - (PUT) genres liked by the current user
    - (PUT) current user's profile image
    - (PUT) current user's recording data
    - (PUT) current user's bio
    - (DELETE) liked genre for current user
    - (DELETE) liked instrument for current user
- Matches Screen
    - (GET) current user's matches (including profile images of the other user in the match)
    - (GET) latest message for each of the current user's match
- DM Chat Screen 
    - (GET) messages between the current user and the other user
    - (POST) create new message by current user (in the DirectMessage table)
    - (PUT) update usersLiked and likes of a message
    - (GET) get latest message in a chat (live polling)
- Events Screen
    - (GET) events organized by current user
    - (GET) events current user was invited to
    - (GET) events current user has accepted
    - (POST) update accepted and invited arrays of an event
- Event Info Screen
    - (GET) event date
    - (GET) event location
    - (GET) event venue
    - (GET) event organizer
    - (GET) event title
    - (GET) users that accepted the event
    - (GET) users that were invited to the event
    - (PUT) event date
    - (PUT) event location
    - (PUT) event title
    - (PUT) event venue
    - (GET) current user's matched users
    - (POST) create new event
- Location Picker screen
    - (GET) venues near location from Foursquare API
    - (GET) invited user's locations
    - (PUT) update event venue
- Login Screen
    - (GET) login
    - (POST) register
- Add Liked Genre Screen
    - (GET) list of genre seeds from Spotify API
    - (POST) new liked genre for current user
- Add Liked Instrument Screen
    - (POST) new liked instrument for current user    

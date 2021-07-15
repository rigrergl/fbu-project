Original App Design Project - README Template
===

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
- **Mobile:** Mobile first design, nearly all users would use the mobile app.
- **Story:** Allows musicians to find friends to play with and share content.
- **Market:** Anybody who plays an instrument, either at a beginner level, intermediate, or advanced.
- **Habit:** Users can find band mates all day long. They can try out different mates and share their performance videos. Very addicting in the same ways that Tinder is. The average user will likely open this app a few times a day, they would create content as well as consume it.
- **Scope:** The MVP of the app would just include matching with nearby musicians. P2 features would include the ability to include share performance videos and messaging inside the app. P3 features would include the ability to follow people (a la instagram) and see a feed of all the posts of people you follow.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can create a new account
* User can login/logout
* Being able to find musicians in your local area
* Being able to post a soundbite 
* Messaging other users (to schedule a meetup)
* Personalized jam buddy suggestions based on preferences and instrument (not just location)

**Optional Nice-to-have Stories**

* Being able to organize jam sessions inside the app and invite people
* In-app groupchats for events
* Using MLKit
* Users are able to post videos instead of soundbites
* Being able to follow people and view their feed
* Experienced musicians can offer paid lessons

### 2. Screen Archetypes

* Login Screen
   * User can login
* Rgistration Screen
   * User can create an account
* Matching screen
   * User can cycle through musician in their local area
   * User can swipe left or right
* Profile Screen
   * User can update location information
   * User can upload videos
* Messaging Screen
   * User can view their matches and enter into DMs with them
   * User can chat with their matches

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Matching Screen
* Profile Screen
* Messaging Screen

**Flow Navigation** (Screen to Screen)

* Login Screen
   * Matching Screen
* Registration Screen
   * Profile Screen

## Wireframes
<img src="https://github.com/rigrergl/fbu-project/blob/main/wireframe_1.jpg" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
### Models
#### User

| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| username    | String      |unique username for user 
| password    | String      |password for user
| location    | String      |last known location of user
| instrumentsPlayed  | Array of String  | instruments the user can play (using application standard name)
| instrumentsSought  | Array of String    | instruments that the user is looking for in jam buddies (used to filter match recommendations) (using application standard name)
| likedGenres  | Array of String    | music genres that the user likes (using application standard name)
| profileImage| File        |profile image for user
| media       | TBD         |media (video, soundbite, or image). Feasibility research required to determine type
| eventsOwned | Array of pointer to Event      |list of events the user created
| eventsInvited | Array of pointer to Event      |list of events the user was invited to
| eventsAccepted | Array of pointer to Event      |list of events the user has accepted
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
| date    | DateTime |time the event is going to happen
| location    | String |address or link of the event
| description    | String |description of the event
| invited    |Array of Pointer to User |list of users that were invited to this event
| accepted    |Array of Pointer to User |list of users that accepted the invitation to this event
| createdAt   | DateTime    |date when like is created (default field)
| updatedAt   | DateTime    |date when like is last updated (default field)



#### DirectMessage
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| createdAt   | DateTime    |date when like is created (default field)
| sender      | Pointer to User    |user that sent the message
| match | Pointer to Conversation   |match this message belongs to
| content     | Strings    |contents of the message
| updatedAt   | DateTime    |date when like is last updated (default field)

#### GroupchatMessage
| Property    | Type        | Description |
| ----------- | ----------- |-------------|
| objectId    | String      |unique id for the user (default field)
| createdAt   | DateTime    |date when like is created (default field)
| sender   | Pointer to User    |user that sent the message
| event   | Pointer to Event    |event that this message was sent to
| content   | Strings    |contents of the message
| updatedAt   | DateTime    |date when like is last updated (default field)



### Networking
## List of Network requests by screen
- Matching Screen
   - (GET) Query all users that fit the logged in user's preferences (and which the logged in user has not already liked)
   - (POST) new like from current user to user in card
- Profile Screen
    - (GET) instruments played by current user
    - (GET) instuments sought by current user
    - (GET) likd genres by current user
    - (GET) current user's profile image
    - (GET) current user's media
    - (PUT) instruments played by current user
    - (PUT) instuments sought by current user
    - (PUT) liked genres by current user
    - (PUT) current user's profile image
    - (PUT) current user's media
- Matches Screen
    - (GET) current user's matches
    - (GET) latest message for each of the current user's match
- DM Chat Screen 
    - (GET) messages between the current user and the other user
    - (POST) create new message by current user (in the DirectMessage table)
- Events Screen
    - (GET) events accepted by current user
    - (GET) events current user was invited to
    - (GET) events current user has accepted
- Event Details Screen
    - (GET) event time
    - (GET) event location
    - (GET) event organizer
    - (GET) event description
    - (GET) users that accepted the event
    - (GET) users that were invited to the event
    - (PUT) event time
    - (PUT) event location
    - (PUT) event description
- New Event Screen
    - (GET) current user's matched users
    - (POST) create new event
- Event Groupchat Screen
    - (GET) messages in the current groupchat
    - (POST) create new message by current user (in the GroupchatMessage table)
- Login Screen
    - (GET) login
    - (POST) register
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]

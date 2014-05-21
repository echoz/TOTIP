# TOTIP: Top of the iTunes Pop

TOTIP is an iOS 7 application that builds queries for RSS feeds based on parameters fetched from http://rss.itunes.apple.com and displays the content in an easy to navigate layout. It is basically a native implementation of the web app.

It is able to fetch, based on the current device locales, localized content to display making use of the localization work already done at http://rss.itunes.apple.com.

## Setup

1. Clone the project
2. `git submodule update --init --recursive`

## File Organization

Directories are named based on their expected feature set. They largely contain a single view controller which implements its namesake along with various other classes (most of the time UI related) that will fully achieve the goal of providing that particular feature.

In the case of TOTIP, the main feature set will be the `List View`, `Query Builder` and `Detail View`.

Other files are the dependencies (Thank you AFNetworking!) used by the project and data model.

## How?

Inherently, starting with a good foundation is always important. In this case, building on a good data model and API would mean that development of UI features would be pretty much straight forward.

Research was done into how the RSS Generator worked and once its operation was worked out, it was translated into the relevant data model objects that govern their respective namesake.

Although the RSS Generator provides everything in `Atom+XML`, it is possible to grab JSON data by replacing the `/xml` prefix with `/json`. Full utilising JSON was decided upon because 2 core classes already used it and that was the native data format that it used. Also a nice JSON mapping super class powered the `TOTIPCountry` and `TOTIPMediaType` classes.

Once the data models were fully built and tested, all that was left was to build the less straight forward part of the app first: The Query Builder. To build a "flow" of options, the primary class used had to be a navigation controller as it could marshal a group of similar class options view controllers.

Finally building the display for data was just an exercise of aesthetic design. In this case, keeping things to a minimal and using system default controls largely helped speed things along.

## Areas for Improvement

- It would be real nice to be able to search the results
- Some amount of caching so we don't have to fetch all the damn time from the server
- Tighter integration with the App/iTunes Store for content
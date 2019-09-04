# Virtual-Tourist
An iOS app that allows user to drop a pin anywhere on the map, and instantly browse nearby Flickr photos. 

This app is a part of Udacity iOS Develeoper Nanodegree.

# Installation
This project does not use any dependencies. 

- Download the project
- Put your API key into the FlickrAPI.swift file
- Deploy it to your device or run it on the simulator.

# How the app works?
- When the app is opened for the first time, user will be met with a MapView.
- When user long presses on the map, new annotation will be added with the locations city name.
- When user selects an annotation, the PhotoAlbumVC will be presented.
- If there are saved photos in the device memory (that is related with the pin), photos are shown in a collection view.
- If there are no photos, a search session will be started on the Flickr with latitude and longitude queries.
- Until the photos are downloaded, the collection view will be presented with placeholder cells.
- As the photos downloaded from the Flickr API, each will be saved and displayed immediately.

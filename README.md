# Dewy

An iOS app that lets you search for books and create "bookshelves" to organize the books that you love, the books that you may want to read and so on.


![Screenshots](/Assets/Screenshots.png)

## How it works

This app uses the [iTunes Search API](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/) to search for books and Core Data to store your saved books. This app also uses the [Sight Engine API](https://sightengine.com/image-quality-main-colors) to detect the dominant colour in a book cover (for displaying purposes). 

## How to use it

1. Go to the [Sight Engine](https://sightengine.com) website to get API keys. (The iTunes Search API does not require any API keys.)

2. This app uses [CocoaPods-keys](https://github.com/orta/cocoapods-keys) to store the API keys. Once you have your API keys, open a terminal in the application's folder and run `pod install`. You will be prompted to enter in the API keys.

3. Open `Dewy.xcworkspace` in Xcode.

6. Build and run the app. 


**Note:** This project is made for personal use only. 


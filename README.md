# NewsByte App

A modern, intuitive news aggregator app developed in Flutter, catering to both Android & iOS platforms. It features a swipeable interface that allows users to seamlessly browse through news articles, summarizing content for quick and efficient reading.

## Table of Contents
1. [Features](#features)
1. [Installation](#installation)
1. [Technical Specs](#technical-specs)
1. [Contributions](#contributions)
1. [License](#license)

## Features
- **Swipeable News Feed:** Engage with news articles through an intuitive swipe interface.
- **Real-Time News Updates:** Stay updated with the latest news fetched in real-time.
- **News Summarization:** Brief summaries of news articles using an integrated summary API.
- **Image Optimization:** Consistent and efficient image display with an image service.
- **Responsive Design:** Adaptability across various device sizes - mobiles.
- **Platform-Specific UI:** Tailored widget styling for Android and iOS.

## Installation
- Clone the repository: `git clone https://github.com/siddhant-vij/NewsByte-App.git`
- Navigate to the project directory: `cd NewsByte-App`
- Install dependencies: `flutter pub get`
- Make a copy of the `config/api.example.config` file & rename it to `api.config`
- Enter your personal API Keys in the `api.config` file
- To run the app in a development environment, use: `flutter run`

## Technical Specs
- **Flutter and Dart**: The app is to be developed using Flutter, compatible with both Android and iOS.
- **State Management**: Manage state changes efficiently using Flutter’s native capabilities.
- **Efficient Data Structures**: Use a double-ended queue (deque) approach for storing news articles, facilitating efficient addition and removal from both ends of the list. Limit memory usage by managing the number of articles in the deque.
- **UI - Swipe Action**: Implement swipe up for next articles and swipe down for previous articles, with a refresh feature at the beginning of the list.
- **Asynchronous Programming**: Use Futures for API calls, & implement Streams for real-time news feed updates.
- **Concurrency Features**: Employ Isolates for CPU-intensive tasks like image processing to ensure UI smoothness.

## Contributions
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.
1. **Fork the Project**
1. **Create your Feature Branch**: 
    ```bash
    git checkout -b feature/AmazingFeature
    ```
1. **Commit your Changes**: 
    ```bash
    git commit -m 'Add some AmazingFeature'
    ```
1. **Push to the Branch**: 
    ```bash
    git push origin feature/AmazingFeature
    ```
1. **Open a Pull Request**

## License
Distributed under the MIT License. See [`LICENSE`](https://github.com/siddhant-vij/NewsByte-App/blob/main/LICENSE) for more information.
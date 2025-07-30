# Jammr
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/atharv1912/Jammr.git)

Jammr is a real-time, collaborative whiteboard application built with Node.js, Express, and Socket.IO. Designed for seamless group interaction, it allows multiple users to draw on a shared canvas simultaneously, making it an ideal tool for brainstorming, teaching, and remote teamwork. The user interface, branded as "StudyBuddy," provides a clean and intuitive experience for creating and joining collaborative sessions.

## Features

*   **Real-Time Collaborative Drawing**: Draw on a shared canvas and see updates from all participants instantly.
*   **Live Cursor Tracking**: See other users' cursors moving across the whiteboard in real-time for enhanced collaboration.
*   **Persistent Room State**: The drawing history for each room is maintained on the server. New participants will instantly see everything that has been drawn before they joined.
*   **Unique Session Rooms**: Create a new private room with a unique URL or join an existing one by its code.
*   **Drawing Toolkit**: A user-friendly toolbar allows you to select different colors and clear the canvas for a fresh start.
*   **Modern Web Interface**: A polished and responsive UI featuring a landing page to create/join rooms and a dedicated collaboration view.

## Tech Stack

*   **Backend**: Node.js, Express
*   **Frontend**: EJS, HTML5, CSS3, JavaScript
*   **Real-Time Engine**: Socket.IO for WebSocket communication.
*   **Peer-to-Peer Framework**: PeerJS
*   **Room Management**: UUID for generating unique room identifiers.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

You need to have Node.js and npm installed on your system.

### Installation & Running the Application

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/atharv1912/Jammr.git
    ```
2.  **Navigate to the project directory:**
    ```sh
    cd Jammr
    ```
3.  **Install the required dependencies:**
    ```sh
    npm install
    ```
4.  **Start the server:**
    ```sh
    node server.js
    ```
5.  Open your web browser and navigate to `http://localhost:3000`.

## How to Use

1.  **Create a Room**: From the homepage, click the **Create Room** button. You will be automatically redirected to a new, unique collaborative session.
2.  **Join a Room**: Click the **Join Room** button and enter the room code (the unique identifier from a room's URL) to join an existing session.
3.  **Collaborate**: Share your room's URL with others to invite them. Use the toolbar on the left to select drawing tools and colors. All changes will be synced in real-time across all participants' screens.
# Ruby on Rails Application with LiveKit

This is a containerized Ruby on Rails application that connects to an external PostgreSQL database and uses LiveKit for real-time media communication.

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Visual Studio Code with Remote - Containers extension
- Git

### Setup Instructions

#### 1. Clone this repository and open in VS Code

```bash
git clone <repository-url>
cd ror_livekit_realtime_meeting
code .
```

#### 2. Open in Dev Container

Click on the green button in the bottom-left corner of VS Code and select "Reopen in Container". This will build your development environment inside a container.

#### 3. Initialize a new Rails application (if starting from scratch)

```bash
# Inside the container terminal
rails new . --database=postgresql --javascript=esbuild --css=tailwind
```

#### 4. Configure the database

Edit `config/database.yml` to connect to your PostgreSQL database running on Docker Desktop:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: host.docker.internal  # Points to your host machine
  port: 5432
  username: postgres          # Update as needed
  password: password          # Update as needed

development:
  <<: *default
  database: ror_livekit_development

test:
  <<: *default
  database: ror_livekit_test

production:
  <<: *default
  database: ror_livekit_production
  username: <%= ENV["DATABASE_USERNAME"] %>
  password: <%= ENV["DATABASE_PASSWORD"] %>
```

#### 5. Initialize the database

```bash
rails db:create
rails db:migrate
```

#### 6. Start the Rails server

```bash
bin/dev
```

Your application will be available at http://localhost:3000

### Managing Rails Credentials

Rails uses an encrypted credentials system for sensitive information:

```bash
# Edit credentials for development
EDITOR=vim rails credentials:edit --environment=development

# Edit credentials for production
EDITOR=vim rails credentials:edit --environment=production
```

Inside the credentials file, you can add:

```yaml
postgres:
  username: your_username
  password: your_password

livekit:
  api_key: your_livekit_api_key
  api_secret: your_livekit_api_secret
```

However, this application will be running in a Kubernetes cluster and will use Kubernetes secrets instead. This means that environment variables can be used directly. For development, create a `dev.env` with the needed environment variables. 

### LiveKit Integration

#### If not installed globally (through the Dockerfile):

To integrate LiveKit for real-time communication:

1. Add the LiveKit gem to your Gemfile:

```ruby
gem 'livekit-server-sdk'
```

2. Install the gem:

```bash
bundle install
```

#### Livekit Token Controller example

1. Create a LiveKit controller:

```bash
rails generate controller LiveKit token room_name:string user_name:string
```

2.Configure the controller to generate tokens:

```ruby
# app/controllers/live_kit_controller.rb
require 'livekit'

class LiveKitController < ApplicationController
  def token
    room_name = params[:room_name]
    user_name = params[:user_name]
    
    api_key = ENV['LIVEKIT_API_KEY']
    api_secret = ENV['LIVEKIT_API_SECRET']
    
    token = LiveKit::AccessToken.new(api_key: api_key, api_secret: api_secret)
    token.identity = user_name
    token.add_grant(room_join: true, room: room_name)
    
    render json: { token: token.to_jwt }
  end
end
```

### Development Workflow

1. Create models: `rails generate model ModelName field:type`
2. Create controllers: `rails generate controller ControllerName action`
3. Define routes in `config/routes.rb`
4. Write your business logic in models and controllers
5. Create views in the `app/views` directory
6. Use `rails c` for an interactive console to test your code
7. Run `rails server` or `bin/dev` to start your development server

### Building for Production

```bash
docker build -t ror_livekit_app .
docker run -p 3000:3000 -e SECRET_KEY_BASE=your_secret_key_base ror_livekit_app
```

## Additional Resources

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [LiveKit Documentation](https://docs.livekit.io/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)


# Platform design 

## Overall description
- The landing page should be a login page with a form for the user to enter their username and password.
- The user should be able to register a new account if they do not have one.
- The landing page should have a title at the top stating "Ruby On Rails Realtime Meeting Platform using LiveKit" or something similar.
- After login the page should show a a grid of rooms, these should be all available rooms in the livekit server. 
- Each room should be represented by a box with the room name and participants count. 
- Somewhere on the page there should be a button to create a new room.
- When the user clicks on a room, they should be taken to a new page where they can join the room. The username connected to the user login will be used and they will be prompted if they want to join with video and/or audio. In this new page they will be presented with a grid layout of all participants in the room. 
- When the user clicks on the create room button, they should be taken to a new page where they can create a new room. The user should be prompted for a room name and username and if they want to enable video and/or audio.
- The user can click on a room card and edit the image on the box which represents the room. The user is asked to choose an image based on images available in the postgres database. 

## System Requirements Specification (SRS)
### 1. Functional Requirements
#### 1.1 User Authentication & Management
- **FR1.1**: Users can register with username and password 
- **FR1.2**: Users can log in with existing credentials
- **FR1.3**: Users can erase their accounts

#### 1.2 Meeting Functionality
- **FR2.1**: Users can create a new meeting room
- **FR2.2**: Users can join an existing meeting room
- **FR2.3**: Users can leave a meeting room
- **FR2.4**: Users can mute/unmute their audio
- **FR2.5**: Users can start/stop their video 
- **FR2.6**: Users can chat in a text channel


### 2. Non-Functional Requirements

#### 2.1 Usability 
- **NFR1.1**: The application should be user-friendly and intuitive on mobile and desktop devices.
- **NFR1.2**: Users can see the the WebRTC RTT time for each participant in the room and connection quality to each participant.
- **NFR1.3**: Users can see all other participants in the room in a grid layout. 
- **NFR1.4**: If a user is not sharing their video, a placeholder image should be shown.
- **NFR1.5**: The landing page after logging in should show a grid of all available rooms.

### Technical Constraints
- **TC1**: The application must be built using Ruby on Rails.
- **TC2**: The application must use PostgreSQL as the database.
- **TC3**: The application must use LiveKit for real-time communication.
- **TC4**: The application must be containerized and natively support deployment on in a Kubernetes cluster. 

# Workflow notes 

- Source `dev.env` file to set up environment variables for the application, make sure to do it BEFORE running `bin/dev` in the terminal. 
- The difference between running commands with `bundle exec rails ` and only `rails` is that the first one will use the gems specified in the Gemfile.lock file, while the second one will use the system gems. This is more important when not using Docker, but it is a good practice to always use `bundle exec` to avoid version conflicts.
- Pay attention to how the token is generated in the Javascript code of app/views/rooms/show.html.erb. The browser hosted code never knows the livekit api key or secret, however the Rails backend has it as environment variables. The javascript code does an AJAX POST request to /rooms/:id/token to get the token. This is safer than having the browser Javascript code know the Livekit credentials. I only needs to know the Livkit URL. 
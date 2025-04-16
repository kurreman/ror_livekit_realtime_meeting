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

### LiveKit Integration

To integrate LiveKit for real-time communication:

1. Add the LiveKit gem to your Gemfile:

```ruby
gem 'livekit-server-sdk'
```

2. Install the gem:

```bash
bundle install
```

3. Create a LiveKit controller:

```bash
rails generate controller LiveKit token room_name:string user_name:string
```

4. Configure the controller to generate tokens:

```ruby
# app/controllers/live_kit_controller.rb
require 'livekit'

class LiveKitController < ApplicationController
  def token
    room_name = params[:room_name]
    user_name = params[:user_name]
    
    api_key = Rails.application.credentials.livekit[:api_key]
    api_secret = Rails.application.credentials.livekit[:api_secret]
    
    token = Livekit::AccessToken.new(api_key: api_key, api_secret: api_secret)
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
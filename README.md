# Metro Train Predictions App 

## Project Overview

### What We're Building
A Metro Train Predictions application with separated Laravel backend and Vue 3 frontend that provides real-time train predictions using the WMATA API.

### Key Features

- Progressive Form Interface: Line → Station → Real-time Predictions
- Ordered Station Display: Stations shown in proper sequence along metro lines
- Real-time Updates: Auto-refreshing predictions every 30 seconds
- Cached Data Management: Static data cached indefinitely, predictions cached 15 seconds
- Rate Limiting & Fault Tolerance: Comprehensive error handling
- **Automatic Data Sync**: WMATA data syncs automatically on startup

### API Integration

- Lines: `GET /Rail.svc/json/jLines` (cached indefinitely)
- Stations: `GET /Rail.svc/json/jStations?LineCode={code}` (cached indefinitely)
- Predictions: `GET /StationPrediction.svc/json/GetPrediction/{stationCode}` (cached 15s)
- Paths: `GET /Rail.svc/json/jPath?FromStationCode={from}&ToStationCode={to}` (cached indefinitely)

### Custom CLI command
- `metro sync` or `docker compose exec laravel-backend php artisan metro:sync` - Full WMATA data sync (runs automatically on startup)
- `metro artisan metro:sync --validate` - Check cache integrity

## **Quick Start** 

### **Requirements**
- Docker & Docker Compose
- Node.js & npm (for local development)
- WMATA API Key ([Get one free here](./Documentation/WMATA-API-key-reg-instructions.md))

### **Installation** 

1. **Clone the repository:**
   ```bash
   git clone https://github.com/DavMorr/wmata-app
   cd wmata-app-test
   ```

2. **Add your WMATA API key:**
   ```bash
   # Edit laravel-app/.env.example and add your WMATA_API_KEY
   ```

3. **Install and start:**
   ```bash
   chmod +x metro-*.sh                 # Make scripts executable
   ./metro-install.sh                  # First-time setup (NO host software installed)
   ```

4. **Optional: Set up unified command system:**
   ```bash
   ./metro-setup-command.sh            # Creates 'metro' command with subcommands
   source ~/.bashrc                     # or ~/.zshrc
   metro help                           # See all available commands
   ```

   **What `metro-setup-command.sh` does:**
   - Adds a `metro()` function to your shell configuration file
   - Enables space-delimited commands: `metro start`, `metro sync`, etc.
   - Provides tab completion for metro commands
   - Only works when run from a Metro project directory
   - **This is optional** - you can always use `./metro-*.sh` scripts directly

5. **Access the application:**
   - **Vue Frontend**: http://localhost:5173/
   - **Laravel API**: http://localhost:8080

### **Daily Development Workflow**

**Option A: Individual Scripts (Always Available)**
```bash
./metro-start.sh                       # Start development environment
./metro-stop.sh                        # Stop all services
./metro-reset.sh                       # Quick reset during development
```

**Option B: Unified Command (After Setup)**
```bash
metro start                            # Start development environment
metro stop                             # Stop all services  
metro reset                            # Quick reset during development
```

## **Testing Setup** (Optional)

**Important**: Testing frameworks are NOT installed by default to avoid installing software to your host system without consent.

### **To Add Testing Capabilities:**
```bash
cd vue-app
npm run test:install                  # Installs Cypress testing framework
npm run test:e2e:dev                  # Open Cypress for interactive testing
npm run test:e2e                      # Run tests headlessly
```

### **Available Test Commands:**
```bash
npm run test:install                  # One-time: Install testing dependencies
npm run test:e2e                      # Run end-to-end tests
npm run test:e2e:dev                  # Interactive test development
npm run test:unit                     # Run component tests
npm run test:unit:dev                 # Interactive component testing
```

**Note**: Testing dependencies (like Cypress) will be installed locally to the project, not globally to your system.

## **Container Architecture**

### **Services & Ports**
| Service | Container | External Port | Purpose |
|---------|-----------|---------------|---------|
| Laravel Backend | `wmata-laravel` | 8080 | API + Apache web server |
| Vue Frontend | `wmata-vue` | 5173 | Vue.js development server |
| MySQL Database | `wmata-mysql` | 33066 | Application database |
| Redis Cache | `wmata-redis` | 63799 | Caching & sessions |

### **Automatic Features**
✅ **Auto Metro Data Sync** - WMATA data syncs on container startup  
✅ **Auto Database Migrations** - Runs automatically  
✅ **Auto Cache Management** - Clears stale cache on startup  
✅ **Health Checks** - All services monitored  

## **Command Structure Explanation**

### **How the Metro Command System Works**

**Without Setup** (Individual Scripts):
```bash
./metro-install.sh                    # Each command is a separate script
./metro-start.sh
./metro-stop.sh
docker compose exec laravel-backend php artisan migrate  # Full Docker commands
```

**With Setup** (Unified Commands):
```bash
metro setup                           # Calls ./metro-install.sh internally
metro start                           # Calls ./metro-start.sh internally  
metro stop                            # Calls ./metro-stop.sh internally
metro artisan migrate                 # Becomes: docker compose exec laravel-backend php artisan migrate
```

### **Special Commands:**

**`metro artisan <anything>`** - Passes arguments to Laravel artisan:
- `metro artisan migrate` → `php artisan migrate`
- `metro artisan make:model User` → `php artisan make:model User`
- `metro artisan route:list` → `php artisan route:list`

**`metro logs [service]`** - View logs with optional service name:
- `metro logs` → Shows Laravel backend logs
- `metro logs vue-frontend` → Shows Vue frontend logs
- `metro logs mysql` → Shows MySQL logs

**Directory-Aware**: The `metro` command only works when you're in a Metro project directory (has `docker-compose.yml`, `laravel-app/`, `vue-app/`).

## **Available Commands**

### **Management Scripts**
```bash
./metro-install.sh                     # First-time installation
./metro-start.sh                       # Start development environment  
./metro-stop.sh                        # Stop all services
./metro-reset.sh                       # Quick reset (clear data, keep images)
./metro-destroy.sh                     # Complete teardown (for distribution)
./metro-setup-command.sh               # Set up unified 'metro' command system
```

**Or with unified commands (after setup):**
```bash
metro setup                            # First-time installation (alias for install)
metro start                            # Start development environment
metro stop                             # Stop all services
metro reset                            # Quick reset (clear data, keep images)
metro destroy                          # Complete teardown (for distribution)
```

### **Docker Commands**
```bash
docker compose up -d                   # Start containers
docker compose down                    # Stop containers
docker compose logs laravel-backend    # View Laravel logs
docker compose ps                      # Check container status
```

### **With Unified Metro Command** (after running `./metro-setup-command.sh`)
```bash
metro setup                            # First-time installation (alias for install)
metro start                            # Start development environment
metro stop                             # Stop all services
metro sync                             # Manual data sync
metro artisan <command>                # Run any Laravel artisan command
metro logs [service]                   # View container logs
metro ps                               # Container status
metro help                             # Show all commands
```

**Examples of `metro artisan` usage:**
```bash
metro artisan migrate                  # Run database migrations
metro artisan route:list               # List all routes
metro artisan cache:clear              # Clear application cache
metro artisan make:controller UserController  # Create new controller
metro artisan queue:work               # Start queue worker
```

## **Development Notes**

### **Data Synchronization**
- **Automatic**: Runs on every container startup
- **Manual**: Use `metro-sync` or `docker compose exec laravel-backend php artisan metro:sync`
- **Validation**: `metro-artisan metro:sync --validate`

### **Cache Management**
- Static data (lines/stations): Cached indefinitely
- Real-time predictions: Cached 15 seconds
- Cache clears automatically on startup

### **Port Configuration**
- **Non-standard ports** prevent conflicts with other local services
- **Laravel**: 8080 (instead of 80)
- **MySQL**: 33066 (instead of 3306)  
- **Redis**: 63799 (instead of 6379)
- **Vue**: 5173 (standard Vite port)

## **Troubleshooting**

### **Common Issues**

**Port conflicts:**
```bash
lsof -i :8080                          # Check what's using port 8080
./metro-stop.sh                        # Stop this app's services
```

**Services not responding:**
```bash
docker compose down                    # Stop everything
./metro-start.sh                       # Fresh start
```

**Empty Metro lines:**
```bash
metro-sync                             # Manual data sync
```

**Container issues:**
```bash
./metro-reset.sh                       # Quick reset (clear data, keep images)
./metro-destroy.sh                     # Complete teardown (removes everything)
./metro-install.sh                     # Fresh installation
```

### **Logs & Debugging**
```bash
metro-logs                             # Laravel logs
metro-vue-logs                         # Vue logs
docker compose logs                    # All service logs
metro-artisan tinker                   # Laravel REPL for debugging
```

## **Documentation**

Comprehensive documentation is included in the [Documentation](./Documentation/) folder:

- [00. Metro Train Prediction App - Service Overview.pdf](./Documentation/00._Metro_Train_Prediction_App_-_Service_Overview.pdf)
- [01. Complete API Documentation.pdf](./Documentation/01._Metro_Train_Prediction_App_-_Complete_API_Documentation.pdf) 
- [02. Database Architecture Guide.pdf](./Documentation/02._Metro_Train_Prediction_App_-_Database_Architecture_Guide.pdf) 
- [03. Service Configuration Guide.pdf](./Documentation/03._Metro_Train_Prediction_App_-_Service_Configuration_Guide.pdf) 
- [04. CLI Command Reference.pdf](./Documentation/04._Metro_Train_Prediction_App_-_CLI_Command_Reference.pdf) 
- [05. Component Integration Guide.pdf](./Documentation/05._Metro_Train_Prediction_App_-_Component_Integration_Guide.pdf) 
- [06. Performance Optimization Guide.pdf](./Documentation/06._Metro_Train_Prediction_App_-_Performance_Optimization_Guide.pdf) 

## **Project Structure**

```
wmata-app-test/
├── metro-install.sh              # First-time setup
├── metro-start.sh                # Start development environment
├── metro-stop.sh                 # Stop all services
├── metro-reset.sh                # Quick reset (clear data, keep images)
├── metro-destroy.sh              # Complete teardown (for distribution)
├── metro-setup-command.sh        # Unified 'metro' command setup
├── docker-compose.yml            # Container orchestration
├── laravel-app/                  # Laravel backend
│   ├── docker-entrypoint.sh     # Container startup script
│   └── [Laravel files]
├── vue-app/                      # Vue frontend
│   └── [Vue.js files]
├── Documentation/                # Complete project documentation
└── backup_original_setup/        # Preserved original scripts
```

## **Distribution & Reset**

### **For Distribution**
To prepare a clean copy for sharing or deployment:

```bash
./metro-destroy.sh                     # Complete teardown
# Project is now ready for distribution
```

### **For Development Reset**
To quickly reset during development:

```bash
./metro-reset.sh                       # Quick reset (keeps images)
./metro-start.sh                       # Restart with fresh data
```

### **Reset Options Comparison**
| Command | Containers | Data | Images | Use Case |
|---------|------------|------|--------|---------|
| `metro-stop.sh` | Stop | Keep | Keep | End work session |
| `metro-reset.sh` | Remove | Clear | Keep | Development reset |
| `metro-destroy.sh` | Remove | Clear | Remove | Distribution prep |

## **Next Steps**

1. **Visit http://localhost:5173** to use the application
2. **Run `./metro-setup-command.sh`** for the unified command system (recommended)
3. **Read the documentation** for advanced configuration and troubleshooting

## **Contact**
- David Morrison - [dave.e.morrison@gmail.com](mailto:dave.e.morrison@gmail.com)
- Project Link: [https://github.com/DavMorr/wmata-app](https://github.com/DavMorr/wmata-app)
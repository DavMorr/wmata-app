# Metro Train Predictions App - Simplified Management

This project now uses a streamlined set of management scripts for easy development workflow. The complex debugging and setup scripts have been consolidated into 3 clean, focused scripts.

## **Available Scripts** ⭐

### **Core Management Scripts**

**`metro-install.sh`** - First-time Installation  
Complete setup for new installations.

- ✅ Validates system requirements (Docker, Node.js)
- ✅ Checks for port conflicts (8080, 5173, 33066, 63799)
- ✅ Sets up Laravel and Vue environment files
- ✅ Installs Vue.js dependencies
- ✅ Builds and starts Docker containers
- ✅ **Automatic Metro data sync on startup**

**`metro-start.sh`** - Start Development Environment  
Daily development startup with automatic features.

- ✅ Checks for port conflicts and resolves them
- ✅ Starts all Docker containers
- ✅ **Automatic Metro data sync**
- ✅ **Automatic database migrations**
- ✅ **Automatic cache clearing**
- ✅ Service health verification

**`metro-stop.sh`** - Stop All Services  
Clean shutdown of the development environment.

- ✅ Gracefully stops all Docker containers
- ✅ Shows final container status
- ✅ Provides helpful next-step commands

### **Optional Enhancement Script**

**`metro-setup-aliases.sh`** - Command Shortcuts Setup  
Creates convenient aliases for common Docker commands.

- `metro-artisan` - Run Laravel artisan commands
- `metro-sync` - Manual Metro data sync
- `metro-tinker` - Laravel REPL
- `metro-logs` - View Laravel logs
- `metro-ps` - Container status

## **Quick Start Workflow**

### **First Time Setup**
```bash
# Make scripts executable
chmod +x metro-*.sh

# Install and start
./metro-install.sh

# Optional: Set up command shortcuts
./metro-setup-aliases.sh
source ~/.bashrc  # or ~/.zshrc
```

### **Daily Development**
```bash
./metro-start.sh                       # Start everything
# ... do development work ...
./metro-stop.sh                        # Stop when done
```

## **Automatic Features** 🚀

### **Container Startup Integration**
The Laravel container now includes an intelligent startup script that:

1. **Waits for database** - Ensures MySQL is ready
2. **Runs migrations** - Keeps database schema current  
3. **Syncs Metro data** - Pulls latest WMATA data automatically
4. **Clears cache** - Removes stale application cache
5. **Starts web server** - Launches Apache with status messages

### **Benefits of Automation**
- ✅ **No manual sync required** - Data syncs on every startup
- ✅ **Consistent state** - Always starts with fresh, current data
- ✅ **Error resilience** - Continues even if sync fails
- ✅ **Developer friendly** - Clear status messages and guidance

## **Command Aliases** (Optional)

After running `./metro-setup-aliases.sh`, you get convenient shortcuts:

```bash
# Instead of: docker compose exec laravel-backend php artisan migrate
metro-artisan migrate

# Instead of: docker compose exec laravel-backend php artisan metro:sync  
metro-sync

# Instead of: docker compose logs laravel-backend
metro-logs

# Instead of: docker compose ps
metro-ps
```

## **Container Architecture**

### **Services Overview**
| Service | Container Name | External Port | Auto-Features |
|---------|---------------|---------------|---------------|
| Laravel | `wmata-laravel` | 8080 | Auto-sync, migrations, cache |
| Vue | `wmata-vue` | 5173 | Hot reload, dev server |
| MySQL | `wmata-mysql` | 33066 | Health checks, data persistence |
| Redis | `wmata-redis` | 63799 | Cache management |

### **Network Configuration**
- **Custom bridge network**: `wmata_network`
- **Internal DNS**: Containers communicate via service names
- **Non-standard ports**: Prevents conflicts with local services

## **Comparison: Before vs After**

### **Before (Complex)**
```
wmata-app-test/
├── install_metro_app.sh              # 200+ lines, complex health checks
├── start_metro_app.sh                # 150+ lines, timeout logic  
├── stop_metro_app.sh                 # 100+ lines, cleanup options
├── debug_laravel.sh                  # Debugging artifact
├── troubleshoot_mysql.sh             # Debugging artifact
├── troubleshoot_redis.sh             # Debugging artifact
├── status_check.sh                   # Debugging artifact
├── setup-sail-alias.sh               # Complex alias setup
├── metro_command_script.sh           # Custom command system
├── make_executable.sh                # Permission management
└── make_all_executable.sh            # More permission scripts
```

### **After (Simplified)**
```
wmata-app-test/
├── metro-install.sh                  # ~60 lines, focused functionality
├── metro-start.sh                    # ~40 lines, clear and simple
├── metro-stop.sh                     # ~25 lines, clean shutdown
├── metro-setup-aliases.sh            # Optional convenience aliases
├── docker-compose.yml                # Container orchestration
├── laravel-app/
│   └── docker-entrypoint.sh         # Intelligent startup automation
└── backup_original_setup/           # All old scripts preserved
```

## **Migration Notes**

### **What Was Removed**
- ❌ Complex health check polling logic
- ❌ Service-specific timeout workarounds
- ❌ Debugging and troubleshooting scripts
- ❌ Custom command alias systems
- ❌ Permission management scripts

### **What Was Improved**
- ✅ **Automatic startup integration** - No manual sync needed
- ✅ **Simplified script logic** - Easy to understand and maintain
- ✅ **Professional error handling** - Clear messages, graceful failures
- ✅ **Standard Docker patterns** - Uses Docker Compose best practices
- ✅ **Preserved functionality** - All essential features maintained

### **Script Preservation**
All original scripts are preserved in `backup_original_setup/` for reference or rollback if needed.

## **Troubleshooting**

### **If Something Goes Wrong**
1. **Check logs**: `metro-logs` or `docker compose logs`
2. **Manual sync**: `metro-sync` or restart containers
3. **Fresh start**: `./metro-stop.sh && ./metro-start.sh`
4. **Reset everything**: `docker compose down --volumes && ./metro-install.sh`

### **Rollback to Old Scripts**
If you need the old complex scripts:
```bash
cp backup_original_setup/*.sh .
chmod +x *.sh
```

## **Benefits of Simplification**

### **For Developers**
- 🎯 **Focused functionality** - Each script has one clear purpose
- 📖 **Easier to understand** - Less complexity, better maintainability
- 🚀 **Faster startup** - Automated processes eliminate manual steps
- 🛡️ **More reliable** - Simplified logic reduces failure points

### **For Maintenance**
- 🔧 **Easier debugging** - Clear, linear script logic
- 📝 **Better documentation** - Self-documenting code with clear messages
- 🔄 **Easier updates** - Simple structure enables quick modifications
- 👥 **Team friendly** - New developers can understand quickly

---

**The result**: A professional, maintainable Metro Train Predictions app that "just works" without complexity overhead.
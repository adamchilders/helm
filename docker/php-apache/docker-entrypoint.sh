#!/bin/bash
set -e

# Function to clone git repository if specified
clone_git_repo() {
    if [ -n "$GIT_REPO_URL" ] && [ -n "$GIT_REPO_TAG" ]; then
        echo "Cloning repository: $GIT_REPO_URL (tag: $GIT_REPO_TAG)"
        
        # Remove existing files except uploads
        find /var/www/html -mindepth 1 -maxdepth 1 ! -name 'uploads' -exec rm -rf {} +
        
        # Clone the repository
        git clone --depth 1 --branch "$GIT_REPO_TAG" "$GIT_REPO_URL" /tmp/repo
        
        # Move files to web root
        mv /tmp/repo/* /var/www/html/ 2>/dev/null || true
        mv /tmp/repo/.[^.]* /var/www/html/ 2>/dev/null || true
        
        # Clean up
        rm -rf /tmp/repo
        
        echo "Repository cloned successfully"
    else
        echo "No git repository specified, using existing files"
    fi
}

# Function to set proper permissions
set_permissions() {
    echo "Setting proper file permissions..."
    chown -R www-data:www-data /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;
    
    # Make uploads directory writable
    if [ -d "/var/www/html/uploads" ]; then
        chmod 775 /var/www/html/uploads
    fi
}

# Function to create a simple index.php if no files exist
create_default_index() {
    if [ ! -f "/var/www/html/index.php" ] && [ ! -f "/var/www/html/index.html" ]; then
        echo "Creating default index.php..."
        cat > /var/www/html/index.php << 'EOF'
<?php
phpinfo();

// Test database connection if environment variables are set
if (isset($_ENV['MYSQL_HOST']) && isset($_ENV['MYSQL_DATABASE'])) {
    echo "<h2>Database Connection Test</h2>";
    try {
        $host = $_ENV['MYSQL_HOST'];
        $db = $_ENV['MYSQL_DATABASE'];
        $user = $_ENV['MYSQL_USER'] ?? 'root';
        $pass = $_ENV['MYSQL_PASSWORD'] ?? '';
        
        $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
        echo "<p style='color: green;'>✅ Database connection successful!</p>";
    } catch (PDOException $e) {
        echo "<p style='color: red;'>❌ Database connection failed: " . $e->getMessage() . "</p>";
    }
}

// Test Redis connection if available
if (class_exists('Redis') && isset($_ENV['REDIS_HOST'])) {
    echo "<h2>Redis Connection Test</h2>";
    try {
        $redis = new Redis();
        $redis->connect($_ENV['REDIS_HOST'], $_ENV['REDIS_PORT'] ?? 6379);
        $redis->set('test_key', 'Hello Redis!');
        $value = $redis->get('test_key');
        echo "<p style='color: green;'>✅ Redis connection successful! Test value: $value</p>";
    } catch (Exception $e) {
        echo "<p style='color: red;'>❌ Redis connection failed: " . $e->getMessage() . "</p>";
    }
}
?>
EOF
    fi
}

# Main execution
echo "Starting PHP 8.4 + Apache container..."

# Clone git repository if specified
clone_git_repo

# Create default index if needed
create_default_index

# Set proper permissions
set_permissions

echo "Container initialization complete. Starting Apache..."

# Execute the original command
exec "$@"

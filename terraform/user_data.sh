#!/bin/bash
set -e

apt-get update
apt-get install -y apache2 php php-mysql php-curl php-json

a2enmod rewrite

systemctl start apache2
systemctl enable apache2

cat > /var/www/html/index.php <<'PHPEOF'
<?php
$db_host = "${db_endpoint}";
$db_name = "${db_name}";
$db_user = "${db_user}";
$db_password = "${db_password}";

echo "<html>";
echo "<head><title>Web Server Status</title></head>";
echo "<body style='font-family: Arial; margin: 20px;'>";
echo "<h1>✓ Web Server Running</h1>";
echo "<p><strong>Hostname:</strong> " . gethostname() . "</p>";
echo "<p><strong>IP Address:</strong> " . $_SERVER['SERVER_ADDR'] . "</p>";
echo "<p><strong>Time:</strong> " . date('Y-m-d H:i:s') . "</p>";
echo "<hr>";

try {
    $dsn = "mysql:host=" . explode(":", $db_host)[0] . ";dbname=" . $db_name;
    $pdo = new PDO($dsn, $db_user, $db_password);
    echo "<h2 style='color: green;'>✓ Database Connection Successful!</h2>";
    echo "<p><strong>Database Host:</strong> " . explode(":", $db_host)[0] . "</p>";
    echo "<p><strong>Database Name:</strong> " . $db_name . "</p>";
} catch (PDOException $e) {
    echo "<h2 style='color: red;'>✗ Database Connection Failed</h2>";
    echo "<p><strong>Error:</strong> " . $e->getMessage() . "</p>";
}

echo "</body>";
echo "</html>";
?>
PHPEOF

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html


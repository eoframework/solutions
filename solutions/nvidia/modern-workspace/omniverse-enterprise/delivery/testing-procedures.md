# NVIDIA Omniverse Enterprise Testing Procedures

## Overview

This document provides comprehensive testing procedures for validating NVIDIA Omniverse Enterprise deployments. The testing framework ensures functionality, performance, security, and integration requirements are met before production deployment.

## Testing Strategy

### Test Phases

**1. Unit Testing**
- Individual component functionality verification
- Service endpoint testing
- Database schema validation
- Configuration parameter testing

**2. Integration Testing**
- Component interaction verification
- Third-party application connector testing
- Authentication system integration
- Network connectivity validation

**3. Performance Testing**
- Load testing with simulated user sessions
- Scalability testing with increasing concurrent users
- Storage I/O performance validation
- Network bandwidth utilization testing

**4. Security Testing**
- Authentication and authorization validation
- Encryption verification
- Vulnerability scanning
- Penetration testing

**5. User Acceptance Testing (UAT)**
- End-to-end workflow validation
- Creative application compatibility
- Collaboration feature testing
- Performance acceptance criteria

## Pre-Deployment Testing

### Infrastructure Validation

**System Requirements Verification**
```bash
#!/bin/bash
# Infrastructure validation script

echo "=== NVIDIA Omniverse Infrastructure Test ==="
echo "Test Date: $(date)"

# Hardware verification
echo "=== Hardware Validation ==="
echo "CPU Cores: $(nproc)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Storage: $(df -h | grep -E '(omniverse|nucleus)')"

# GPU validation
echo "=== GPU Validation ==="
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader

# Network validation
echo "=== Network Validation ==="
ping -c 3 8.8.8.8
speedtest-cli --simple

# Storage performance
echo "=== Storage Performance ==="
dd if=/dev/zero of=/tmp/test_write bs=1M count=1000 conv=fdatasync 2>&1 | \
   grep -E '(copied|MB/s)'
rm /tmp/test_write
```

**Service Dependencies Check**
```bash
#!/bin/bash
# Service dependency validation

services=("postgresql" "nginx" "nucleus-server" "nucleus-navigator")

for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "✓ $service: Running"
    else
        echo "✗ $service: Not running"
        exit 1
    fi
done

# Database connectivity
sudo -u postgres psql -c "SELECT version();" > /dev/null && \
    echo "✓ Database: Connected" || echo "✗ Database: Connection failed"

# API endpoint validation
curl -s -f https://localhost/health > /dev/null && \
    echo "✓ API: Accessible" || echo "✗ API: Not accessible"
```

### Configuration Testing

**Nucleus Server Configuration**
```python
#!/usr/bin/env python3
"""Nucleus server configuration validation"""

import yaml
import json
import requests
import os

def validate_nucleus_config():
    """Validate Nucleus server configuration"""
    config_path = "/opt/ove/nucleus/config/nucleus-server.yml"
    
    try:
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        
        # Test database connection parameters
        db_config = config.get('database', {})
        required_db_params = ['host', 'port', 'database', 'username']
        
        for param in required_db_params:
            assert param in db_config, f"Missing database parameter: {param}"
        
        # Test SSL configuration
        ssl_config = config.get('ssl', {})
        if ssl_config.get('enabled', False):
            cert_file = ssl_config.get('certificate')
            key_file = ssl_config.get('private_key')
            
            assert os.path.exists(cert_file), f"SSL certificate not found: {cert_file}"
            assert os.path.exists(key_file), f"SSL private key not found: {key_file}"
        
        # Test authentication configuration
        auth_config = config.get('authentication', {})
        if 'ldap' in auth_config:
            ldap_config = auth_config['ldap']
            required_ldap_params = ['server', 'base_dn', 'bind_dn']
            
            for param in required_ldap_params:
                assert param in ldap_config, f"Missing LDAP parameter: {param}"
        
        print("✓ Nucleus configuration validation passed")
        return True
        
    except Exception as e:
        print(f"✗ Nucleus configuration validation failed: {e}")
        return False

def test_api_endpoints():
    """Test critical API endpoints"""
    base_url = "https://localhost"
    
    endpoints = [
        "/health",
        "/api/v1/version",
        "/api/v1/users",
        "/api/v1/projects"
    ]
    
    headers = {
        "Authorization": f"Bearer {os.getenv('NUCLEUS_API_TOKEN')}"
    }
    
    for endpoint in endpoints:
        try:
            response = requests.get(f"{base_url}{endpoint}", 
                                  headers=headers, 
                                  verify=False, 
                                  timeout=10)
            
            if response.status_code in [200, 401]:  # 401 expected without proper auth
                print(f"✓ API endpoint {endpoint}: Accessible")
            else:
                print(f"✗ API endpoint {endpoint}: Failed ({response.status_code})")
                return False
                
        except Exception as e:
            print(f"✗ API endpoint {endpoint}: Error - {e}")
            return False
    
    return True

if __name__ == "__main__":
    config_valid = validate_nucleus_config()
    api_valid = test_api_endpoints()
    
    if config_valid and api_valid:
        print("✓ Configuration testing completed successfully")
    else:
        print("✗ Configuration testing failed")
        exit(1)
```

## Functional Testing

### Core Functionality Tests

**User Authentication Testing**
```python
#!/usr/bin/env python3
"""User authentication testing suite"""

import requests
import json
import time

class AuthenticationTest:
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.verify = False  # For testing only
    
    def test_local_authentication(self):
        """Test local user authentication"""
        auth_data = {
            "username": "test_user",
            "password": "test_password"
        }
        
        response = self.session.post(
            f"{self.base_url}/api/v1/auth/login",
            json=auth_data
        )
        
        if response.status_code == 200:
            token = response.json().get('token')
            print("✓ Local authentication: Success")
            return token
        else:
            print(f"✗ Local authentication: Failed ({response.status_code})")
            return None
    
    def test_ldap_authentication(self):
        """Test LDAP authentication"""
        auth_data = {
            "username": "ldap_user@domain.com",
            "password": "ldap_password"
        }
        
        response = self.session.post(
            f"{self.base_url}/api/v1/auth/ldap",
            json=auth_data
        )
        
        if response.status_code == 200:
            print("✓ LDAP authentication: Success")
            return response.json().get('token')
        else:
            print(f"✗ LDAP authentication: Failed ({response.status_code})")
            return None
    
    def test_token_validation(self, token):
        """Test token validation and user info retrieval"""
        headers = {"Authorization": f"Bearer {token}"}
        
        response = self.session.get(
            f"{self.base_url}/api/v1/user/profile",
            headers=headers
        )
        
        if response.status_code == 200:
            user_info = response.json()
            print(f"✓ Token validation: Success (User: {user_info.get('username')})")
            return True
        else:
            print(f"✗ Token validation: Failed ({response.status_code})")
            return False

def run_authentication_tests():
    """Run all authentication tests"""
    test_suite = AuthenticationTest("https://localhost")
    
    # Test local authentication
    local_token = test_suite.test_local_authentication()
    if local_token:
        test_suite.test_token_validation(local_token)
    
    # Test LDAP authentication (if configured)
    ldap_token = test_suite.test_ldap_authentication()
    if ldap_token:
        test_suite.test_token_validation(ldap_token)

if __name__ == "__main__":
    run_authentication_tests()
```

**Asset Management Testing**
```bash
#!/bin/bash
# Asset management functionality testing

echo "=== Asset Management Testing ==="

API_TOKEN="your-api-token-here"
BASE_URL="https://localhost/api/v1"

# Test asset upload
echo "Testing asset upload..."
curl -X POST "$BASE_URL/assets/upload" \
     -H "Authorization: Bearer $API_TOKEN" \
     -F "file=@test-assets/sample.usd" \
     -F "project=test-project"

if [ $? -eq 0 ]; then
    echo "✓ Asset upload: Success"
else
    echo "✗ Asset upload: Failed"
fi

# Test asset listing
echo "Testing asset listing..."
ASSETS_RESPONSE=$(curl -s "$BASE_URL/assets" \
                      -H "Authorization: Bearer $API_TOKEN")

if echo "$ASSETS_RESPONSE" | jq -e '.assets' > /dev/null; then
    echo "✓ Asset listing: Success"
    ASSET_COUNT=$(echo "$ASSETS_RESPONSE" | jq '.assets | length')
    echo "  Total assets: $ASSET_COUNT"
else
    echo "✗ Asset listing: Failed"
fi

# Test asset download
echo "Testing asset download..."
FIRST_ASSET_ID=$(echo "$ASSETS_RESPONSE" | jq -r '.assets[0].id')

curl -s "$BASE_URL/assets/$FIRST_ASSET_ID/download" \
     -H "Authorization: Bearer $API_TOKEN" \
     -o /tmp/downloaded_asset.usd

if [ -f /tmp/downloaded_asset.usd ]; then
    echo "✓ Asset download: Success"
    rm /tmp/downloaded_asset.usd
else
    echo "✗ Asset download: Failed"
fi

# Test asset metadata
echo "Testing asset metadata..."
METADATA_RESPONSE=$(curl -s "$BASE_URL/assets/$FIRST_ASSET_ID/metadata" \
                        -H "Authorization: Bearer $API_TOKEN")

if echo "$METADATA_RESPONSE" | jq -e '.metadata' > /dev/null; then
    echo "✓ Asset metadata: Success"
else
    echo "✗ Asset metadata: Failed"
fi
```

### Collaboration Testing

**Real-time Collaboration Test**
```python
#!/usr/bin/env python3
"""Real-time collaboration testing"""

import asyncio
import websockets
import json
import time
import threading

class CollaborationTest:
    def __init__(self, server_url, auth_token):
        self.server_url = server_url
        self.auth_token = auth_token
        self.clients = []
        self.messages_received = []
    
    async def client_session(self, client_id, project_id):
        """Simulate a client collaboration session"""
        uri = f"wss://{self.server_url}/collaboration/{project_id}"
        headers = {"Authorization": f"Bearer {self.auth_token}"}
        
        try:
            async with websockets.connect(uri, extra_headers=headers) as websocket:
                # Join collaboration session
                join_message = {
                    "type": "join",
                    "client_id": client_id,
                    "project_id": project_id
                }
                await websocket.send(json.dumps(join_message))
                
                # Listen for messages
                async for message in websocket:
                    data = json.loads(message)
                    self.messages_received.append({
                        "client": client_id,
                        "timestamp": time.time(),
                        "message": data
                    })
                    
                    # Send test modification
                    if data.get("type") == "user_joined":
                        modification = {
                            "type": "scene_update",
                            "client_id": client_id,
                            "changes": [
                                {
                                    "object_id": "test_cube",
                                    "property": "transform.position",
                                    "value": [client_id, 0, 0]
                                }
                            ]
                        }
                        await websocket.send(json.dumps(modification))
                        
        except Exception as e:
            print(f"Client {client_id} error: {e}")
    
    def run_collaboration_test(self, num_clients=3, duration=30):
        """Run collaboration test with multiple clients"""
        print(f"Starting collaboration test with {num_clients} clients for {duration}s")
        
        project_id = "test-collaboration-project"
        
        # Start client sessions
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        tasks = []
        for i in range(num_clients):
            task = loop.create_task(self.client_session(f"client_{i}", project_id))
            tasks.append(task)
        
        # Run for specified duration
        try:
            loop.run_until_complete(asyncio.wait_for(
                asyncio.gather(*tasks), timeout=duration
            ))
        except asyncio.TimeoutError:
            print("Collaboration test completed (timeout reached)")
        
        # Analyze results
        self.analyze_collaboration_results()
    
    def analyze_collaboration_results(self):
        """Analyze collaboration test results"""
        if not self.messages_received:
            print("✗ Collaboration test: No messages received")
            return
        
        # Check message distribution
        client_messages = {}
        for msg in self.messages_received:
            client = msg["client"]
            if client not in client_messages:
                client_messages[client] = 0
            client_messages[client] += 1
        
        print("✓ Collaboration test: Messages received")
        for client, count in client_messages.items():
            print(f"  {client}: {count} messages")
        
        # Check latency
        join_times = {}
        update_times = {}
        
        for msg in self.messages_received:
            if msg["message"].get("type") == "user_joined":
                join_times[msg["client"]] = msg["timestamp"]
            elif msg["message"].get("type") == "scene_update":
                update_times[msg["client"]] = msg["timestamp"]
        
        # Calculate collaboration latency
        latencies = []
        for client in join_times:
            if client in update_times:
                latency = update_times[client] - join_times[client]
                latencies.append(latency)
        
        if latencies:
            avg_latency = sum(latencies) / len(latencies)
            print(f"✓ Average collaboration latency: {avg_latency:.3f}s")
        else:
            print("✗ Could not calculate collaboration latency")

if __name__ == "__main__":
    test = CollaborationTest("localhost", "test-token")
    test.run_collaboration_test()
```

## Performance Testing

### Load Testing

**Concurrent User Load Test**
```python
#!/usr/bin/env python3
"""Load testing for concurrent users"""

import asyncio
import aiohttp
import time
import statistics
from concurrent.futures import ThreadPoolExecutor

class LoadTest:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url
        self.auth_token = auth_token
        self.results = []
    
    async def simulate_user_session(self, session, user_id):
        """Simulate a typical user session"""
        headers = {"Authorization": f"Bearer {self.auth_token}"}
        
        session_metrics = {
            "user_id": user_id,
            "start_time": time.time(),
            "operations": []
        }
        
        try:
            # Login operation
            start = time.time()
            async with session.get(f"{self.base_url}/api/v1/user/profile", 
                                 headers=headers) as response:
                await response.json()
            
            session_metrics["operations"].append({
                "operation": "login",
                "duration": time.time() - start,
                "status": response.status
            })
            
            # List projects
            start = time.time()
            async with session.get(f"{self.base_url}/api/v1/projects", 
                                 headers=headers) as response:
                projects = await response.json()
            
            session_metrics["operations"].append({
                "operation": "list_projects",
                "duration": time.time() - start,
                "status": response.status
            })
            
            # Load assets from first project
            if projects.get("projects"):
                project_id = projects["projects"][0]["id"]
                start = time.time()
                async with session.get(
                    f"{self.base_url}/api/v1/projects/{project_id}/assets",
                    headers=headers
                ) as response:
                    await response.json()
                
                session_metrics["operations"].append({
                    "operation": "load_assets",
                    "duration": time.time() - start,
                    "status": response.status
                })
            
        except Exception as e:
            session_metrics["error"] = str(e)
        
        session_metrics["total_duration"] = time.time() - session_metrics["start_time"]
        return session_metrics
    
    async def run_load_test(self, concurrent_users=10, duration=60):
        """Run load test with specified concurrent users"""
        print(f"Starting load test: {concurrent_users} concurrent users for {duration}s")
        
        connector = aiohttp.TCPConnector(limit=concurrent_users * 2)
        timeout = aiohttp.ClientTimeout(total=30)
        
        async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
            start_time = time.time()
            user_tasks = []
            
            # Start user sessions
            for user_id in range(concurrent_users):
                task = asyncio.create_task(
                    self.simulate_user_session(session, user_id)
                )
                user_tasks.append(task)
            
            # Run sessions and collect results
            while time.time() - start_time < duration:
                # Complete any finished sessions
                done_tasks = [task for task in user_tasks if task.done()]
                for task in done_tasks:
                    result = await task
                    self.results.append(result)
                    user_tasks.remove(task)
                    
                    # Start new session to maintain concurrent load
                    new_user_id = len(self.results)
                    new_task = asyncio.create_task(
                        self.simulate_user_session(session, new_user_id)
                    )
                    user_tasks.append(new_task)
                
                await asyncio.sleep(1)
            
            # Wait for remaining tasks to complete
            for task in user_tasks:
                if not task.done():
                    task.cancel()
    
    def analyze_results(self):
        """Analyze load test results"""
        if not self.results:
            print("✗ No load test results to analyze")
            return
        
        # Overall metrics
        total_sessions = len(self.results)
        successful_sessions = sum(1 for r in self.results if "error" not in r)
        error_rate = (total_sessions - successful_sessions) / total_sessions * 100
        
        print(f"✓ Load Test Results:")
        print(f"  Total sessions: {total_sessions}")
        print(f"  Successful sessions: {successful_sessions}")
        print(f"  Error rate: {error_rate:.1f}%")
        
        # Response time analysis
        durations = [r["total_duration"] for r in self.results if "error" not in r]
        if durations:
            avg_duration = statistics.mean(durations)
            median_duration = statistics.median(durations)
            p95_duration = sorted(durations)[int(len(durations) * 0.95)]
            
            print(f"  Average session duration: {avg_duration:.2f}s")
            print(f"  Median session duration: {median_duration:.2f}s")
            print(f"  95th percentile duration: {p95_duration:.2f}s")
        
        # Operation-specific metrics
        operations = {}
        for result in self.results:
            if "operations" in result:
                for op in result["operations"]:
                    op_name = op["operation"]
                    if op_name not in operations:
                        operations[op_name] = []
                    operations[op_name].append(op["duration"])
        
        for op_name, durations in operations.items():
            avg_duration = statistics.mean(durations)
            print(f"  {op_name} average duration: {avg_duration:.3f}s")

async def main():
    load_test = LoadTest("https://localhost", "test-token")
    await load_test.run_load_test(concurrent_users=20, duration=120)
    load_test.analyze_results()

if __name__ == "__main__":
    asyncio.run(main())
```

### Storage Performance Testing

**Storage I/O Performance Test**
```bash
#!/bin/bash
# Storage performance testing for Omniverse assets

echo "=== Storage Performance Testing ==="

STORAGE_PATH="/opt/ove/nucleus/data"
TEST_DIR="$STORAGE_PATH/performance-test"

# Create test directory
mkdir -p "$TEST_DIR"

echo "Testing sequential write performance..."
dd if=/dev/zero of="$TEST_DIR/test_seq_write" bs=1M count=1000 conv=fdatasync 2>&1 | \
   grep -E "(copied|MB/s)"

echo "Testing sequential read performance..."
dd if="$TEST_DIR/test_seq_write" of=/dev/null bs=1M 2>&1 | \
   grep -E "(copied|MB/s)"

echo "Testing random I/O performance..."
fio --name=random-rw-test \
    --filename="$TEST_DIR/test_random_io" \
    --size=1G \
    --rw=randrw \
    --bs=4k \
    --numjobs=4 \
    --time_based \
    --runtime=60 \
    --ioengine=libaio \
    --iodepth=32 \
    --direct=1

echo "Testing small file operations (typical for USD assets)..."
mkdir -p "$TEST_DIR/small_files"

# Create test files
for i in {1..1000}; do
    dd if=/dev/urandom of="$TEST_DIR/small_files/file_$i.usd" bs=1k count=100 2>/dev/null
done

# Time file listing operation
time ls -la "$TEST_DIR/small_files" > /dev/null

# Time file deletion
time rm -rf "$TEST_DIR/small_files"

# Cleanup
rm -rf "$TEST_DIR"

echo "Storage performance testing completed"
```

## Security Testing

### Vulnerability Assessment

**Security Scan Script**
```bash
#!/bin/bash
# Security vulnerability assessment

echo "=== Security Vulnerability Assessment ==="

# Network port scanning
echo "Scanning open ports..."
nmap -sS -sV localhost | grep -E "(open|filtered)"

# SSL/TLS configuration testing
echo "Testing SSL/TLS configuration..."
sslscan --show-certificate localhost:443

# Web application security testing
echo "Testing web application security headers..."
curl -I https://localhost | grep -E "(X-|Strict-Transport|Content-Security)"

# Authentication brute force protection
echo "Testing authentication rate limiting..."
for i in {1..10}; do
    curl -s -X POST https://localhost/api/v1/auth/login \
         -d '{"username":"test","password":"wrong"}' \
         -H "Content-Type: application/json"
done

# Check for common vulnerabilities
echo "Checking for common web vulnerabilities..."

# SQL injection test
curl -s "https://localhost/api/v1/assets?search='; DROP TABLE users; --" | \
     grep -i "error\|sql\|database" && echo "Potential SQL injection vulnerability"

# XSS test
curl -s "https://localhost/api/v1/search?q=<script>alert('xss')</script>" | \
     grep "<script>" && echo "Potential XSS vulnerability"

echo "Security assessment completed"
```

**Access Control Testing**
```python
#!/usr/bin/env python3
"""Access control and authorization testing"""

import requests
import json

class SecurityTest:
    def __init__(self, base_url):
        self.base_url = base_url
    
    def test_unauthorized_access(self):
        """Test that protected resources require authentication"""
        protected_endpoints = [
            "/api/v1/user/profile",
            "/api/v1/projects",
            "/api/v1/assets",
            "/api/v1/admin/users"
        ]
        
        print("Testing unauthorized access protection...")
        
        for endpoint in protected_endpoints:
            response = requests.get(f"{self.base_url}{endpoint}")
            
            if response.status_code == 401:
                print(f"✓ {endpoint}: Properly protected")
            else:
                print(f"✗ {endpoint}: Not properly protected ({response.status_code})")
    
    def test_role_based_access(self):
        """Test role-based access control"""
        # Test with regular user token
        user_token = "user-test-token"
        admin_token = "admin-test-token"
        
        headers_user = {"Authorization": f"Bearer {user_token}"}
        headers_admin = {"Authorization": f"Bearer {admin_token}"}
        
        # Admin-only endpoints
        admin_endpoints = [
            "/api/v1/admin/users",
            "/api/v1/admin/settings",
            "/api/v1/admin/logs"
        ]
        
        print("Testing role-based access control...")
        
        for endpoint in admin_endpoints:
            # Test with regular user (should fail)
            user_response = requests.get(f"{self.base_url}{endpoint}", 
                                       headers=headers_user)
            
            if user_response.status_code == 403:
                print(f"✓ {endpoint}: User access properly denied")
            else:
                print(f"✗ {endpoint}: User access not properly denied")
            
            # Test with admin user (should succeed)
            admin_response = requests.get(f"{self.base_url}{endpoint}", 
                                        headers=headers_admin)
            
            if admin_response.status_code == 200:
                print(f"✓ {endpoint}: Admin access granted")
            else:
                print(f"✗ {endpoint}: Admin access denied")
    
    def test_data_validation(self):
        """Test input validation and sanitization"""
        print("Testing input validation...")
        
        # Test SQL injection
        malicious_inputs = [
            "'; DROP TABLE users; --",
            "' OR '1'='1",
            "<script>alert('xss')</script>",
            "../../../etc/passwd",
            "\"; system('rm -rf /'); \""
        ]
        
        for malicious_input in malicious_inputs:
            response = requests.get(
                f"{self.base_url}/api/v1/search",
                params={"q": malicious_input}
            )
            
            # Check if malicious input is reflected in response
            if malicious_input.lower() in response.text.lower():
                print(f"✗ Input validation: Malicious input reflected")
            else:
                print(f"✓ Input validation: Malicious input sanitized")

def run_security_tests():
    """Run all security tests"""
    security_test = SecurityTest("https://localhost")
    
    security_test.test_unauthorized_access()
    security_test.test_role_based_access()
    security_test.test_data_validation()

if __name__ == "__main__":
    run_security_tests()
```

## Integration Testing

### Third-Party Application Testing

**Application Connector Test**
```python
#!/usr/bin/env python3
"""Test third-party application connectors"""

import subprocess
import time
import os

class ConnectorTest:
    def __init__(self):
        self.test_results = {}
    
    def test_maya_connector(self):
        """Test Autodesk Maya connector"""
        print("Testing Maya Omniverse Connector...")
        
        # Check if Maya is available
        try:
            maya_path = r"C:\Program Files\Autodesk\Maya2024\bin\maya.exe"
            if not os.path.exists(maya_path):
                print("✗ Maya not found - skipping connector test")
                return False
            
            # Test Maya connector loading
            maya_script = """
import maya.cmds as cmds
import sys

# Add Omniverse connector path
sys.path.append('C:/Users/Public/Documents/Omniverse/Connectors/Maya')

try:
    import omniverse_maya_connector
    print("Omniverse connector loaded successfully")
    
    # Test basic connectivity
    connector.connect_to_nucleus("nucleus-server.company.com")
    print("Connected to Nucleus server")
    
    # Test asset operations
    connector.list_projects()
    print("Project listing successful")
    
    cmds.quit(force=True)
except Exception as e:
    print(f"Connector test failed: {e}")
    cmds.quit(exitCode=1)
"""
            
            # Run Maya with test script
            result = subprocess.run([
                maya_path, "-batch", "-command", maya_script
            ], capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                print("✓ Maya connector: Working")
                return True
            else:
                print(f"✗ Maya connector: Failed - {result.stderr}")
                return False
                
        except Exception as e:
            print(f"✗ Maya connector test error: {e}")
            return False
    
    def test_blender_connector(self):
        """Test Blender Omniverse Connector"""
        print("Testing Blender Omniverse Connector...")
        
        try:
            blender_script = """
import bpy
import sys
import os

# Add Omniverse addon path
addon_path = os.path.expanduser("~/.config/blender/3.6/scripts/addons/omniverse_connector")
sys.path.append(addon_path)

try:
    # Enable Omniverse addon
    bpy.ops.preferences.addon_enable(module="omniverse_connector")
    
    # Test connection
    import omniverse_connector
    connector = omniverse_connector.get_connector_instance()
    connector.connect("nucleus-server.company.com")
    
    print("Blender Omniverse connector working")
    bpy.ops.wm.quit_blender()
    
except Exception as e:
    print(f"Blender connector error: {e}")
    bpy.ops.wm.quit_blender()
"""
            
            result = subprocess.run([
                "blender", "--background", "--python-expr", blender_script
            ], capture_output=True, text=True, timeout=300)
            
            if "connector working" in result.stdout:
                print("✓ Blender connector: Working")
                return True
            else:
                print(f"✗ Blender connector: Failed - {result.stderr}")
                return False
                
        except Exception as e:
            print(f"✗ Blender connector test error: {e}")
            return False
    
    def test_unreal_connector(self):
        """Test Unreal Engine Omniverse Connector"""
        print("Testing Unreal Engine Omniverse Connector...")
        
        # This would require Unreal Engine automation framework
        # Simplified version for demonstration
        try:
            # Check if Unreal connector plugin is available
            plugin_path = r"C:\Program Files\Epic Games\UE_5.3\Engine\Plugins\Marketplace\OmniverseConnector"
            
            if os.path.exists(plugin_path):
                print("✓ Unreal connector: Plugin found")
                return True
            else:
                print("✗ Unreal connector: Plugin not found")
                return False
                
        except Exception as e:
            print(f"✗ Unreal connector test error: {e}")
            return False

def run_connector_tests():
    """Run all connector tests"""
    test_suite = ConnectorTest()
    
    results = {
        "maya": test_suite.test_maya_connector(),
        "blender": test_suite.test_blender_connector(),
        "unreal": test_suite.test_unreal_connector()
    }
    
    print("\n=== Connector Test Summary ===")
    for connector, result in results.items():
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{connector.title()} Connector: {status}")

if __name__ == "__main__":
    run_connector_tests()
```

## User Acceptance Testing

### End-to-End Workflow Testing

**Creative Workflow Test**
```python
#!/usr/bin/env python3
"""End-to-end creative workflow testing"""

import time
import requests
import json

class WorkflowTest:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url
        self.auth_token = auth_token
        self.headers = {"Authorization": f"Bearer {auth_token}"}
    
    def test_complete_workflow(self):
        """Test complete creative workflow from start to finish"""
        print("=== End-to-End Creative Workflow Test ===")
        
        # Step 1: Create new project
        project_data = {
            "name": "UAT Test Project",
            "description": "User acceptance testing project",
            "template": "default"
        }
        
        response = requests.post(
            f"{self.base_url}/api/v1/projects",
            json=project_data,
            headers=self.headers
        )
        
        if response.status_code == 201:
            project = response.json()
            project_id = project["id"]
            print(f"✓ Project created: {project_id}")
        else:
            print(f"✗ Project creation failed: {response.status_code}")
            return False
        
        # Step 2: Upload initial assets
        test_assets = ["test_model.usd", "test_texture.jpg", "test_material.mdl"]
        uploaded_assets = []
        
        for asset_name in test_assets:
            # Simulate asset upload
            asset_data = {
                "name": asset_name,
                "project_id": project_id,
                "size": 1024000,  # 1MB
                "type": asset_name.split(".")[-1]
            }
            
            response = requests.post(
                f"{self.base_url}/api/v1/assets",
                json=asset_data,
                headers=self.headers
            )
            
            if response.status_code == 201:
                asset = response.json()
                uploaded_assets.append(asset)
                print(f"✓ Asset uploaded: {asset_name}")
            else:
                print(f"✗ Asset upload failed: {asset_name}")
        
        # Step 3: Create collaborative session
        session_data = {
            "project_id": project_id,
            "session_name": "UAT Collaboration Test",
            "max_users": 5
        }
        
        response = requests.post(
            f"{self.base_url}/api/v1/sessions",
            json=session_data,
            headers=self.headers
        )
        
        if response.status_code == 201:
            session = response.json()
            session_id = session["id"]
            print(f"✓ Collaboration session created: {session_id}")
        else:
            print(f"✗ Collaboration session creation failed: {response.status_code}")
        
        # Step 4: Simulate multi-user collaboration
        users = ["user1@company.com", "user2@company.com", "user3@company.com"]
        
        for user_email in users:
            join_data = {"session_id": session_id, "user_email": user_email}
            
            response = requests.post(
                f"{self.base_url}/api/v1/sessions/{session_id}/join",
                json=join_data,
                headers=self.headers
            )
            
            if response.status_code == 200:
                print(f"✓ User joined session: {user_email}")
            else:
                print(f"✗ User join failed: {user_email}")
        
        # Step 5: Test asset modifications and versioning
        for asset in uploaded_assets[:1]:  # Test with first asset
            modification_data = {
                "asset_id": asset["id"],
                "changes": [
                    {
                        "property": "transform.position",
                        "value": [1.0, 2.0, 3.0]
                    }
                ],
                "comment": "UAT modification test"
            }
            
            response = requests.post(
                f"{self.base_url}/api/v1/assets/{asset['id']}/modify",
                json=modification_data,
                headers=self.headers
            )
            
            if response.status_code == 200:
                print(f"✓ Asset modified: {asset['name']}")
            else:
                print(f"✗ Asset modification failed: {asset['name']}")
        
        # Step 6: Test version history
        response = requests.get(
            f"{self.base_url}/api/v1/assets/{uploaded_assets[0]['id']}/versions",
            headers=self.headers
        )
        
        if response.status_code == 200:
            versions = response.json()
            if len(versions["versions"]) > 1:
                print(f"✓ Version history working: {len(versions['versions'])} versions")
            else:
                print("✗ Version history not working")
        
        # Step 7: Test rendering and preview generation
        render_data = {
            "asset_id": uploaded_assets[0]["id"],
            "render_settings": {
                "resolution": [1920, 1080],
                "quality": "high",
                "format": "png"
            }
        }
        
        response = requests.post(
            f"{self.base_url}/api/v1/render",
            json=render_data,
            headers=self.headers
        )
        
        if response.status_code == 202:  # Accepted for processing
            render_job = response.json()
            print(f"✓ Render job started: {render_job['id']}")
            
            # Poll for completion
            for _ in range(30):  # Wait up to 30 seconds
                status_response = requests.get(
                    f"{self.base_url}/api/v1/render/{render_job['id']}/status",
                    headers=self.headers
                )
                
                if status_response.status_code == 200:
                    status = status_response.json()
                    if status["status"] == "completed":
                        print("✓ Render job completed")
                        break
                    elif status["status"] == "failed":
                        print("✗ Render job failed")
                        break
                
                time.sleep(1)
        
        # Step 8: Test export functionality
        export_data = {
            "project_id": project_id,
            "format": "usd",
            "include_assets": True,
            "compression": True
        }
        
        response = requests.post(
            f"{self.base_url}/api/v1/projects/{project_id}/export",
            json=export_data,
            headers=self.headers
        )
        
        if response.status_code == 202:
            export_job = response.json()
            print(f"✓ Export job started: {export_job['id']}")
        else:
            print(f"✗ Export job failed to start: {response.status_code}")
        
        # Cleanup
        requests.delete(
            f"{self.base_url}/api/v1/projects/{project_id}",
            headers=self.headers
        )
        
        print("✓ End-to-End workflow test completed")
        return True

def run_uat_tests():
    """Run User Acceptance Tests"""
    workflow_test = WorkflowTest("https://localhost", "uat-test-token")
    workflow_test.test_complete_workflow()

if __name__ == "__main__":
    run_uat_tests()
```

## Test Reporting

### Automated Test Report Generation

**Test Report Generator**
```python
#!/usr/bin/env python3
"""Automated test report generation"""

import json
import datetime
import os
from jinja2 import Template

class TestReporter:
    def __init__(self):
        self.test_results = {}
        self.start_time = datetime.datetime.now()
    
    def add_test_result(self, test_suite, test_name, status, details=None):
        """Add a test result to the report"""
        if test_suite not in self.test_results:
            self.test_results[test_suite] = []
        
        self.test_results[test_suite].append({
            "name": test_name,
            "status": status,
            "details": details,
            "timestamp": datetime.datetime.now().isoformat()
        })
    
    def generate_html_report(self):
        """Generate HTML test report"""
        template_html = """
<!DOCTYPE html>
<html>
<head>
    <title>NVIDIA Omniverse Enterprise Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #76b900; color: white; padding: 20px; }
        .summary { margin: 20px 0; }
        .test-suite { margin: 20px 0; border: 1px solid #ccc; }
        .suite-header { background-color: #f0f0f0; padding: 10px; font-weight: bold; }
        .test-result { padding: 10px; border-bottom: 1px solid #eee; }
        .pass { color: green; }
        .fail { color: red; }
        .warning { color: orange; }
    </style>
</head>
<body>
    <div class="header">
        <h1>NVIDIA Omniverse Enterprise Test Report</h1>
        <p>Generated: {{ report_date }}</p>
        <p>Duration: {{ duration }}</p>
    </div>
    
    <div class="summary">
        <h2>Test Summary</h2>
        <ul>
            <li>Total Test Suites: {{ total_suites }}</li>
            <li>Total Tests: {{ total_tests }}</li>
            <li>Passed: {{ passed_tests }}</li>
            <li>Failed: {{ failed_tests }}</li>
            <li>Success Rate: {{ success_rate }}%</li>
        </ul>
    </div>
    
    {% for suite_name, tests in test_results.items() %}
    <div class="test-suite">
        <div class="suite-header">{{ suite_name }}</div>
        {% for test in tests %}
        <div class="test-result">
            <span class="{{ test.status }}">{{ test.status.upper() }}</span> - {{ test.name }}
            {% if test.details %}
            <div style="margin-top: 5px; font-size: 0.9em; color: #666;">
                {{ test.details }}
            </div>
            {% endif %}
        </div>
        {% endfor %}
    </div>
    {% endfor %}
</body>
</html>
"""
        
        # Calculate summary statistics
        total_tests = sum(len(tests) for tests in self.test_results.values())
        passed_tests = sum(1 for tests in self.test_results.values() 
                          for test in tests if test["status"] == "pass")
        failed_tests = total_tests - passed_tests
        success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
        
        # Render template
        template = Template(template_html)
        html_content = template.render(
            report_date=self.start_time.strftime("%Y-%m-%d %H:%M:%S"),
            duration=str(datetime.datetime.now() - self.start_time),
            total_suites=len(self.test_results),
            total_tests=total_tests,
            passed_tests=passed_tests,
            failed_tests=failed_tests,
            success_rate=round(success_rate, 1),
            test_results=self.test_results
        )
        
        # Save report
        report_filename = f"omniverse_test_report_{self.start_time.strftime('%Y%m%d_%H%M%S')}.html"
        with open(report_filename, 'w') as f:
            f.write(html_content)
        
        print(f"Test report generated: {report_filename}")
        return report_filename
    
    def generate_json_report(self):
        """Generate JSON test report for automation"""
        report_data = {
            "timestamp": self.start_time.isoformat(),
            "duration": str(datetime.datetime.now() - self.start_time),
            "test_results": self.test_results,
            "summary": {
                "total_suites": len(self.test_results),
                "total_tests": sum(len(tests) for tests in self.test_results.values()),
                "passed": sum(1 for tests in self.test_results.values() 
                             for test in tests if test["status"] == "pass"),
                "failed": sum(1 for tests in self.test_results.values() 
                             for test in tests if test["status"] == "fail")
            }
        }
        
        report_filename = f"omniverse_test_report_{self.start_time.strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_filename, 'w') as f:
            json.dump(report_data, f, indent=2)
        
        return report_filename

# Example usage
if __name__ == "__main__":
    reporter = TestReporter()
    
    # Example test results
    reporter.add_test_result("Infrastructure", "System Requirements Check", "pass")
    reporter.add_test_result("Infrastructure", "Service Status", "pass")
    reporter.add_test_result("Functional", "User Authentication", "pass")
    reporter.add_test_result("Functional", "Asset Management", "fail", "Upload timeout")
    reporter.add_test_result("Performance", "Load Test", "pass")
    reporter.add_test_result("Security", "Access Control", "pass")
    
    html_report = reporter.generate_html_report()
    json_report = reporter.generate_json_report()
    
    print(f"Reports generated: {html_report}, {json_report}")
```

This comprehensive testing procedures document provides systematic validation of all aspects of NVIDIA Omniverse Enterprise deployment, ensuring reliability, performance, and security before production use.
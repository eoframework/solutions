# Testing Procedures - Cisco Secure Access

## Overview

This document provides comprehensive testing procedures for validating Cisco Secure Access solution implementation. These procedures ensure all components function correctly and security policies are properly enforced before go-live.

## Table of Contents

1. [Pre-Implementation Testing](#pre-implementation-testing)
2. [Component Testing](#component-testing)
3. [Integration Testing](#integration-testing)
4. [Security Policy Testing](#security-policy-testing)
5. [Performance Testing](#performance-testing)
6. [User Acceptance Testing](#user-acceptance-testing)
7. [Disaster Recovery Testing](#disaster-recovery-testing)
8. [Go-Live Readiness Testing](#go-live-readiness-testing)

---

## Pre-Implementation Testing

### Infrastructure Validation

#### Network Connectivity Testing

**Test Case: TC-NET-001 - Basic Network Connectivity**
- **Objective**: Verify network connectivity between all components
- **Prerequisites**: Network infrastructure deployed
- **Test Steps**:
  1. Test ping connectivity from ISE nodes to domain controllers
  2. Test ping connectivity from ASA to ISE nodes
  3. Test ping connectivity from switches to ISE nodes
  4. Verify DNS resolution for all FQDNs

```bash
#!/bin/bash
# network-connectivity-test.sh
# Test basic network connectivity

echo "=== Network Connectivity Test ==="

# Test connectivity to ISE nodes
echo "Testing ISE connectivity..."
ping -c 4 ise-primary.company.com || echo "❌ ISE Primary unreachable"
ping -c 4 ise-secondary.company.com || echo "❌ ISE Secondary unreachable"

# Test connectivity to domain controllers
echo "Testing Active Directory connectivity..."
ping -c 4 dc01.company.com || echo "❌ DC01 unreachable"
ping -c 4 dc02.company.com || echo "❌ DC02 unreachable"

# Test DNS resolution
echo "Testing DNS resolution..."
nslookup ise-primary.company.com || echo "❌ DNS resolution failed"
nslookup vpn-primary.company.com || echo "❌ VPN DNS resolution failed"

# Test port connectivity
echo "Testing port connectivity..."
nc -zv 192.168.1.50 443 || echo "❌ ISE HTTPS port unreachable"
nc -zv 192.168.1.50 1812 || echo "❌ RADIUS auth port unreachable"
nc -zv 192.168.1.50 1813 || echo "❌ RADIUS acct port unreachable"

echo "Network connectivity test completed"
```

**Expected Results**:
- All ping tests successful
- DNS resolution working for all FQDNs
- All required ports accessible

**Test Case: TC-NET-002 - Certificate Validation**
- **Objective**: Verify SSL certificate configuration and trust chains
- **Prerequisites**: Certificates installed on all components
- **Test Steps**:
  1. Verify ISE certificate validity and chain
  2. Verify ASA certificate validity and chain
  3. Test certificate-based authentication

```bash
#!/bin/bash
# certificate-validation-test.sh
# Test SSL certificate configuration

echo "=== Certificate Validation Test ==="

# Test ISE certificate
echo "Testing ISE certificate..."
openssl s_client -connect ise-primary.company.com:8443 -servername ise-primary.company.com 2>/dev/null | openssl x509 -noout -dates

# Test ASA certificate
echo "Testing ASA certificate..."
openssl s_client -connect vpn-primary.company.com:443 -servername vpn-primary.company.com 2>/dev/null | openssl x509 -noout -dates

# Verify certificate chain
echo "Verifying certificate chains..."
openssl s_client -connect ise-primary.company.com:8443 -showcerts

echo "Certificate validation test completed"
```

---

## Component Testing

### ISE Component Testing

**Test Case: TC-ISE-001 - ISE Service Startup**
- **Objective**: Verify ISE services start correctly
- **Prerequisites**: ISE nodes deployed with basic configuration
- **Test Steps**:
  1. Restart ISE services on primary node
  2. Monitor service startup logs
  3. Verify web interface accessibility
  4. Test admin login functionality

```python
#!/usr/bin/env python3
# ise-service-test.py
# Test ISE service functionality

import requests
import time
import json

class ISEServiceTest:
    def __init__(self):
        self.ise_primary = "https://ise-primary.company.com:8443"
        self.ise_secondary = "https://ise-secondary.company.com:8443"
        self.admin_credentials = ('admin', 'admin_password')
    
    def test_web_interface(self):
        """Test ISE web interface accessibility"""
        try:
            response = requests.get(f"{self.ise_primary}/admin/", 
                                  timeout=10, verify=False)
            if response.status_code == 200:
                print("✓ ISE Primary web interface accessible")
                return True
            else:
                print(f"❌ ISE Primary web interface failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ ISE Primary web interface error: {e}")
            return False
    
    def test_admin_login(self):
        """Test admin login functionality"""
        try:
            session = requests.Session()
            session.verify = False
            
            # Get login page
            login_page = session.get(f"{self.ise_primary}/admin/")
            
            # Simulate login (actual implementation would parse form)
            login_data = {
                'username': self.admin_credentials[0],
                'password': self.admin_credentials[1]
            }
            
            login_response = session.post(f"{self.ise_primary}/admin/login.jsp", 
                                        data=login_data)
            
            if "dashboard" in login_response.text.lower():
                print("✓ ISE admin login successful")
                return True
            else:
                print("❌ ISE admin login failed")
                return False
                
        except Exception as e:
            print(f"❌ ISE admin login error: {e}")
            return False
    
    def test_radius_service(self):
        """Test RADIUS service functionality"""
        import subprocess
        
        try:
            # Use radtest utility to test RADIUS authentication
            result = subprocess.run([
                'radtest', 'testuser', 'testpass', 
                '192.168.1.50', '1812', 'testing123'
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0 and "Access-Accept" in result.stdout:
                print("✓ RADIUS authentication test successful")
                return True
            else:
                print(f"❌ RADIUS authentication test failed: {result.stdout}")
                return False
                
        except Exception as e:
            print(f"❌ RADIUS service test error: {e}")
            return False

# Run ISE service tests
ise_test = ISEServiceTest()
ise_test.test_web_interface()
ise_test.test_admin_login()
ise_test.test_radius_service()
```

**Test Case: TC-ISE-002 - Active Directory Integration**
- **Objective**: Verify ISE can authenticate against Active Directory
- **Prerequisites**: ISE joined to AD domain, test user accounts created
- **Test Steps**:
  1. Test LDAP connectivity from ISE to domain controllers
  2. Perform test authentication with AD user account
  3. Verify group membership retrieval
  4. Test user attribute retrieval

### Umbrella Component Testing

**Test Case: TC-UMB-001 - DNS Security Validation**
- **Objective**: Verify Umbrella DNS security is blocking malicious domains
- **Prerequisites**: Umbrella policies configured and applied
- **Test Steps**:
  1. Test DNS resolution through Umbrella resolvers
  2. Attempt to resolve known malicious domains
  3. Verify legitimate domains resolve correctly
  4. Test custom block/allow lists

```python
#!/usr/bin/env python3
# umbrella-dns-test.py
# Test Umbrella DNS security functionality

import socket
import dns.resolver
import requests

class UmbrellaDNSTest:
    def __init__(self):
        self.umbrella_dns = ['208.67.222.222', '208.67.220.220']
        self.test_domains = {
            'legitimate': ['google.com', 'microsoft.com', 'cisco.com'],
            'malicious': ['malware-test.umbrella.com', 'phishing-test.umbrella.com'],
            'blocked_category': ['facebook.com']  # If social media blocked
        }
    
    def test_dns_resolution(self):
        """Test DNS resolution through Umbrella"""
        resolver = dns.resolver.Resolver()
        resolver.nameservers = self.umbrella_dns
        
        # Test legitimate domains
        print("Testing legitimate domain resolution...")
        for domain in self.test_domains['legitimate']:
            try:
                answer = resolver.resolve(domain, 'A')
                print(f"✓ {domain} resolved to {answer[0]}")
            except Exception as e:
                print(f"❌ {domain} resolution failed: {e}")
        
        # Test malicious domains (should be blocked)
        print("\nTesting malicious domain blocking...")
        for domain in self.test_domains['malicious']:
            try:
                answer = resolver.resolve(domain, 'A')
                # Check if resolved to Umbrella block page
                if str(answer[0]) in ['146.112.61.104', '146.112.61.105']:
                    print(f"✓ {domain} correctly blocked by Umbrella")
                else:
                    print(f"❌ {domain} not blocked: {answer[0]}")
            except Exception as e:
                print(f"✓ {domain} blocked (DNS exception): {e}")
    
    def test_web_filtering(self):
        """Test web filtering through Umbrella proxy"""
        # Configure requests to use Umbrella proxy if applicable
        print("\nTesting web filtering...")
        
        for domain in self.test_domains['blocked_category']:
            try:
                response = requests.get(f"http://{domain}", timeout=10)
                if "blocked" in response.text.lower() or response.status_code == 403:
                    print(f"✓ {domain} correctly blocked by web filter")
                else:
                    print(f"❌ {domain} not blocked by web filter")
            except Exception as e:
                print(f"Web filter test for {domain}: {e}")

# Run Umbrella tests
umbrella_test = UmbrellaDNSTest()
umbrella_test.test_dns_resolution()
umbrella_test.test_web_filtering()
```

### VPN Component Testing

**Test Case: TC-VPN-001 - AnyConnect Client Connection**
- **Objective**: Verify AnyConnect clients can establish VPN connections
- **Prerequisites**: ASA configured, AnyConnect profiles deployed
- **Test Steps**:
  1. Install AnyConnect client on test devices
  2. Test certificate-based authentication
  3. Test username/password authentication
  4. Verify split tunneling configuration
  5. Test host compliance checking

```bash
#!/bin/bash
# anyconnect-test.sh
# Test AnyConnect VPN functionality

echo "=== AnyConnect VPN Test ==="

# Test VPN gateway accessibility
echo "Testing VPN gateway accessibility..."
curl -k -I https://vpn-primary.company.com/ || echo "❌ VPN gateway unreachable"

# Test AnyConnect profile download
echo "Testing AnyConnect profile download..."
curl -k -o test_profile.xml https://vpn-primary.company.com/profiles/AnyConnect_Client_Profile.xml
if [ -f "test_profile.xml" ]; then
    echo "✓ AnyConnect profile downloaded successfully"
    # Validate XML profile
    xmllint --noout test_profile.xml && echo "✓ Profile XML is valid" || echo "❌ Profile XML is invalid"
else
    echo "❌ Failed to download AnyConnect profile"
fi

# Test SSL VPN portal
echo "Testing SSL VPN portal..."
curl -k -s https://vpn-primary.company.com/ | grep -i "anyconnect" && echo "✓ SSL VPN portal accessible" || echo "❌ SSL VPN portal issues"

echo "AnyConnect VPN test completed"
```

---

## Integration Testing

### End-to-End Authentication Flow

**Test Case: TC-INT-001 - 802.1X Authentication Flow**
- **Objective**: Verify complete 802.1X authentication from endpoint to network access
- **Prerequisites**: Switch configured, ISE policies in place, test devices available
- **Test Steps**:
  1. Connect test device to 802.1X enabled port
  2. Monitor authentication process in ISE
  3. Verify correct VLAN assignment
  4. Test network access based on authorization policy
  5. Verify accounting records

```python
#!/usr/bin/env python3
# dot1x-integration-test.py
# Test complete 802.1X authentication flow

import requests
import time
import subprocess
from datetime import datetime, timedelta

class Dot1XIntegrationTest:
    def __init__(self):
        self.ise_url = "https://ise-primary.company.com:9060/ers"
        self.headers = {'Content-Type': 'application/json'}
        self.auth = ('admin', 'admin_password')
    
    def simulate_device_connection(self, mac_address, username):
        """Simulate device connection and authentication"""
        print(f"Simulating device connection: {mac_address}, user: {username}")
        
        # This would typically involve actual device connection
        # For testing, we'll simulate the authentication flow
        
        # Step 1: Check if device appears in ISE live sessions
        time.sleep(5)  # Wait for authentication to process
        
        # Step 2: Query ISE for active session
        session_info = self.get_active_session(mac_address)
        
        if session_info:
            print(f"✓ Authentication successful for {mac_address}")
            print(f"  User: {session_info.get('user', 'N/A')}")
            print(f"  VLAN: {session_info.get('vlan', 'N/A')}")
            print(f"  Authorization Profile: {session_info.get('profile', 'N/A')}")
            return True
        else:
            print(f"❌ Authentication failed for {mac_address}")
            return False
    
    def get_active_session(self, mac_address):
        """Get active session information from ISE"""
        try:
            # Query ISE monitoring API for active sessions
            url = f"{self.ise_url}/config/activesession"
            response = requests.get(url, headers=self.headers, 
                                  auth=self.auth, verify=False)
            
            if response.status_code == 200:
                sessions = response.json()
                # Filter for specific MAC address
                for session in sessions.get('sessions', []):
                    if session.get('mac_address') == mac_address:
                        return session
            
            return None
            
        except Exception as e:
            print(f"Error querying active sessions: {e}")
            return None
    
    def test_policy_enforcement(self, mac_address, expected_vlan):
        """Test that correct policies are enforced"""
        print(f"Testing policy enforcement for {mac_address}")
        
        # Get session information
        session_info = self.get_active_session(mac_address)
        
        if session_info:
            actual_vlan = session_info.get('vlan')
            if actual_vlan == expected_vlan:
                print(f"✓ Correct VLAN assigned: {actual_vlan}")
                return True
            else:
                print(f"❌ Incorrect VLAN: expected {expected_vlan}, got {actual_vlan}")
                return False
        else:
            print(f"❌ No active session found for {mac_address}")
            return False
    
    def test_accounting_records(self, mac_address):
        """Verify RADIUS accounting records are created"""
        print(f"Testing accounting records for {mac_address}")
        
        # Query ISE for accounting records in the last 10 minutes
        try:
            # This would query ISE monitoring and troubleshooting logs
            url = f"{self.ise_url}/config/radiusaccounting"
            params = {
                'mac_address': mac_address,
                'timeframe': '10m'
            }
            
            response = requests.get(url, headers=self.headers, 
                                  auth=self.auth, params=params, verify=False)
            
            if response.status_code == 200:
                records = response.json()
                if records.get('records'):
                    print(f"✓ Accounting records found for {mac_address}")
                    return True
                else:
                    print(f"❌ No accounting records found for {mac_address}")
                    return False
            else:
                print(f"❌ Failed to query accounting records: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"Error querying accounting records: {e}")
            return False

# Run integration tests
test = Dot1XIntegrationTest()

# Test scenarios
test_scenarios = [
    {'mac': '00:11:22:33:44:55', 'user': 'jdoe', 'expected_vlan': '200'},
    {'mac': '00:11:22:33:44:56', 'user': 'guest', 'expected_vlan': '300'}
]

for scenario in test_scenarios:
    print(f"\n=== Testing scenario: {scenario} ===")
    test.simulate_device_connection(scenario['mac'], scenario['user'])
    test.test_policy_enforcement(scenario['mac'], scenario['expected_vlan'])
    test.test_accounting_records(scenario['mac'])
```

### Multi-Factor Authentication Integration

**Test Case: TC-INT-002 - Duo MFA Integration**
- **Objective**: Verify Duo MFA integration with ISE authentication
- **Prerequisites**: Duo configured, test user enrolled
- **Test Steps**:
  1. Initiate authentication that requires MFA
  2. Verify Duo push notification sent
  3. Test approval and denial flows
  4. Verify fallback authentication methods

---

## Security Policy Testing

### Access Control Policy Testing

**Test Case: TC-SEC-001 - Role-Based Access Control**
- **Objective**: Verify users receive appropriate access based on role
- **Prerequisites**: RBAC policies configured, test users in different roles
- **Test Steps**:
  1. Test executive user access (full network access)
  2. Test standard employee access (limited network access)
  3. Test contractor access (restricted access)
  4. Test guest access (internet-only access)
  5. Verify access restrictions are enforced

```python
#!/usr/bin/env python3
# rbac-policy-test.py
# Test role-based access control policies

import requests
import socket
import subprocess

class RBACPolicyTest:
    def __init__(self):
        self.test_users = {
            'executive': {'username': 'ceo', 'expected_access': 'full'},
            'employee': {'username': 'jdoe', 'expected_access': 'standard'},
            'contractor': {'username': 'contractor1', 'expected_access': 'limited'},
            'guest': {'username': 'guest1', 'expected_access': 'internet_only'}
        }
        
        self.access_tests = {
            'internal_server': {'host': '10.1.1.100', 'port': 80},
            'file_server': {'host': '10.1.2.100', 'port': 445},
            'database_server': {'host': '10.1.3.100', 'port': 1433},
            'internet': {'host': '8.8.8.8', 'port': 53}
        }
    
    def test_user_access(self, username, expected_access_level):
        """Test network access for a specific user"""
        print(f"Testing access for user: {username} (expected: {expected_access_level})")
        
        # Simulate user authentication and get session info
        # In real implementation, this would authenticate as the user
        
        results = {}
        
        for resource, connection in self.access_tests.items():
            accessible = self.test_resource_access(connection['host'], connection['port'])
            results[resource] = accessible
            
            # Check if access matches expected policy
            expected = self.should_have_access(resource, expected_access_level)
            
            if accessible == expected:
                status = "✓"
            else:
                status = "❌"
            
            print(f"  {status} {resource}: {'Accessible' if accessible else 'Blocked'} (Expected: {'Accessible' if expected else 'Blocked'})")
        
        return results
    
    def test_resource_access(self, host, port, timeout=5):
        """Test if a network resource is accessible"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            result = sock.connect_ex((host, port))
            sock.close()
            return result == 0
        except Exception:
            return False
    
    def should_have_access(self, resource, access_level):
        """Determine if user should have access based on policy"""
        access_matrix = {
            'full': ['internal_server', 'file_server', 'database_server', 'internet'],
            'standard': ['internal_server', 'file_server', 'internet'],
            'limited': ['internal_server', 'internet'],
            'internet_only': ['internet']
        }
        
        return resource in access_matrix.get(access_level, [])
    
    def run_all_tests(self):
        """Run RBAC tests for all user types"""
        print("=== Role-Based Access Control Testing ===")
        
        for role, user_info in self.test_users.items():
            print(f"\n--- Testing {role.upper()} Role ---")
            results = self.test_user_access(user_info['username'], user_info['expected_access'])

# Run RBAC policy tests
rbac_test = RBACPolicyTest()
rbac_test.run_all_tests()
```

### Threat Protection Testing

**Test Case: TC-SEC-002 - Malware Detection and Blocking**
- **Objective**: Verify Umbrella blocks malware and phishing attempts
- **Prerequisites**: Umbrella security policies active
- **Test Steps**:
  1. Attempt to access known malware domains
  2. Test phishing website blocking
  3. Verify file download blocking
  4. Test custom threat intelligence integration

---

## Performance Testing

### Load Testing

**Test Case: TC-PERF-001 - Authentication Load Test**
- **Objective**: Verify system performance under concurrent authentication load
- **Prerequisites**: Test environment with load generation capability
- **Test Steps**:
  1. Generate concurrent authentication requests
  2. Monitor response times and success rates
  3. Identify performance bottlenecks
  4. Validate system remains stable under load

```python
#!/usr/bin/env python3
# authentication-load-test.py
# Load test authentication performance

import threading
import time
import requests
import statistics
from concurrent.futures import ThreadPoolExecutor, as_completed

class AuthenticationLoadTest:
    def __init__(self):
        self.ise_url = "https://ise-primary.company.com:9060/ers"
        self.results = []
        self.success_count = 0
        self.failure_count = 0
        self.response_times = []
    
    def simulate_authentication(self, user_id):
        """Simulate single authentication attempt"""
        start_time = time.time()
        
        try:
            # Simulate RADIUS authentication
            import subprocess
            result = subprocess.run([
                'radtest', f'testuser{user_id}', 'testpass', 
                '192.168.1.50', '1812', 'testing123'
            ], capture_output=True, text=True, timeout=30)
            
            end_time = time.time()
            response_time = end_time - start_time
            
            if result.returncode == 0:
                self.success_count += 1
                status = 'success'
            else:
                self.failure_count += 1
                status = 'failure'
            
            self.response_times.append(response_time)
            
            return {
                'user_id': user_id,
                'status': status,
                'response_time': response_time,
                'timestamp': time.time()
            }
            
        except Exception as e:
            end_time = time.time()
            response_time = end_time - start_time
            self.failure_count += 1
            
            return {
                'user_id': user_id,
                'status': 'error',
                'response_time': response_time,
                'error': str(e),
                'timestamp': time.time()
            }
    
    def run_load_test(self, concurrent_users=100, duration_seconds=300):
        """Run load test with specified parameters"""
        print(f"Starting load test: {concurrent_users} concurrent users for {duration_seconds} seconds")
        
        start_time = time.time()
        user_id = 0
        
        with ThreadPoolExecutor(max_workers=concurrent_users) as executor:
            futures = []
            
            while time.time() - start_time < duration_seconds:
                # Submit authentication task
                future = executor.submit(self.simulate_authentication, user_id)
                futures.append(future)
                user_id += 1
                
                # Small delay to control rate
                time.sleep(0.1)
            
            # Collect results
            for future in as_completed(futures):
                try:
                    result = future.result(timeout=60)
                    self.results.append(result)
                except Exception as e:
                    print(f"Authentication task failed: {e}")
        
        self.generate_report()
    
    def generate_report(self):
        """Generate load test report"""
        print("\n=== Load Test Results ===")
        
        total_requests = len(self.results)
        success_rate = (self.success_count / total_requests) * 100 if total_requests > 0 else 0
        
        print(f"Total Requests: {total_requests}")
        print(f"Successful: {self.success_count}")
        print(f"Failed: {self.failure_count}")
        print(f"Success Rate: {success_rate:.2f}%")
        
        if self.response_times:
            avg_response = statistics.mean(self.response_times)
            p95_response = statistics.quantiles(self.response_times, n=20)[18]
            p99_response = statistics.quantiles(self.response_times, n=100)[98]
            
            print(f"\nResponse Time Statistics:")
            print(f"Average: {avg_response:.3f}s")
            print(f"95th Percentile: {p95_response:.3f}s")
            print(f"99th Percentile: {p99_response:.3f}s")
            print(f"Min: {min(self.response_times):.3f}s")
            print(f"Max: {max(self.response_times):.3f}s")
        
        # Performance thresholds
        if success_rate >= 95 and avg_response <= 2.0:
            print("\n✓ Performance test PASSED")
        else:
            print("\n❌ Performance test FAILED")
            if success_rate < 95:
                print(f"  - Success rate below threshold: {success_rate:.2f}% < 95%")
            if avg_response > 2.0:
                print(f"  - Average response time above threshold: {avg_response:.3f}s > 2.0s")

# Run load test
load_test = AuthenticationLoadTest()
load_test.run_load_test(concurrent_users=50, duration_seconds=60)
```

---

## User Acceptance Testing

### End User Experience Testing

**Test Case: TC-UAT-001 - Employee Onboarding Experience**
- **Objective**: Verify smooth user experience for new employee onboarding
- **Prerequisites**: Test user account and device prepared
- **Test Steps**:
  1. New employee receives device and credentials
  2. Connect to corporate network for first time
  3. Complete device registration process
  4. Test access to required business applications
  5. Verify help desk can assist with issues

**Test Case: TC-UAT-002 - Remote Worker VPN Experience**
- **Objective**: Verify remote workers can easily connect and work productively
- **Prerequisites**: AnyConnect deployed, remote test environment
- **Test Steps**:
  1. Install AnyConnect client on personal/BYOD device
  2. Connect to VPN from remote location
  3. Test access to internal business applications
  4. Verify acceptable performance for typical work activities
  5. Test reconnection after network interruption

---

## Test Execution and Reporting

### Automated Test Execution

```bash
#!/bin/bash
# run-all-tests.sh
# Execute complete test suite

echo "=== Cisco Secure Access Test Suite ==="
echo "Start Time: $(date)"

TEST_RESULTS_DIR="test-results-$(date +%Y%m%d-%H%M%S)"
mkdir -p $TEST_RESULTS_DIR

# Pre-implementation tests
echo "Running pre-implementation tests..."
./network-connectivity-test.sh > $TEST_RESULTS_DIR/network-test.log 2>&1
./certificate-validation-test.sh > $TEST_RESULTS_DIR/cert-test.log 2>&1

# Component tests
echo "Running component tests..."
python3 ise-service-test.py > $TEST_RESULTS_DIR/ise-test.log 2>&1
python3 umbrella-dns-test.py > $TEST_RESULTS_DIR/umbrella-test.log 2>&1
./anyconnect-test.sh > $TEST_RESULTS_DIR/anyconnect-test.log 2>&1

# Integration tests
echo "Running integration tests..."
python3 dot1x-integration-test.py > $TEST_RESULTS_DIR/integration-test.log 2>&1

# Security policy tests
echo "Running security policy tests..."
python3 rbac-policy-test.py > $TEST_RESULTS_DIR/rbac-test.log 2>&1

# Performance tests
echo "Running performance tests..."
python3 authentication-load-test.py > $TEST_RESULTS_DIR/performance-test.log 2>&1

echo "Test execution completed. Results saved to: $TEST_RESULTS_DIR"
echo "End Time: $(date)"

# Generate summary report
python3 generate-test-report.py --results-dir $TEST_RESULTS_DIR
```

### Test Report Generation

```python
#!/usr/bin/env python3
# generate-test-report.py
# Generate comprehensive test report

import os
import json
import argparse
from datetime import datetime

class TestReportGenerator:
    def __init__(self, results_dir):
        self.results_dir = results_dir
        self.test_results = {}
        self.summary = {
            'total_tests': 0,
            'passed_tests': 0,
            'failed_tests': 0,
            'success_rate': 0
        }
    
    def parse_test_results(self):
        """Parse test result files"""
        for filename in os.listdir(self.results_dir):
            if filename.endswith('.log'):
                test_name = filename.replace('.log', '').replace('-', '_')
                
                with open(os.path.join(self.results_dir, filename), 'r') as f:
                    content = f.read()
                    
                # Simple parsing logic - count ✓ and ❌ symbols
                passed = content.count('✓')
                failed = content.count('❌')
                
                self.test_results[test_name] = {
                    'passed': passed,
                    'failed': failed,
                    'status': 'PASS' if failed == 0 else 'FAIL',
                    'log_file': filename
                }
                
                self.summary['total_tests'] += 1
                if failed == 0:
                    self.summary['passed_tests'] += 1
                else:
                    self.summary['failed_tests'] += 1
        
        if self.summary['total_tests'] > 0:
            self.summary['success_rate'] = (self.summary['passed_tests'] / self.summary['total_tests']) * 100
    
    def generate_html_report(self):
        """Generate HTML test report"""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Cisco Secure Access Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #0073e6; color: white; padding: 20px; text-align: center; }
        .summary { background-color: #f0f8ff; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .test-results { margin: 20px 0; }
        .test-item { margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        .pass { background-color: #d4edda; border-color: #c3e6cb; }
        .fail { background-color: #f8d7da; border-color: #f5c6cb; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Cisco Secure Access Test Report</h1>
        <p>Generated: {timestamp}</p>
    </div>
    
    <div class="summary">
        <h2>Test Summary</h2>
        <p><strong>Total Tests:</strong> {total_tests}</p>
        <p><strong>Passed:</strong> {passed_tests}</p>
        <p><strong>Failed:</strong> {failed_tests}</p>
        <p><strong>Success Rate:</strong> {success_rate:.1f}%</p>
    </div>
    
    <div class="test-results">
        <h2>Detailed Test Results</h2>
        <table>
            <thead>
                <tr>
                    <th>Test Name</th>
                    <th>Status</th>
                    <th>Passed</th>
                    <th>Failed</th>
                    <th>Log File</th>
                </tr>
            </thead>
            <tbody>
                {test_rows}
            </tbody>
        </table>
    </div>
</body>
</html>
        """
        
        # Generate table rows
        test_rows = ""
        for test_name, results in self.test_results.items():
            status_class = "pass" if results['status'] == 'PASS' else "fail"
            test_rows += f"""
                <tr class="{status_class}">
                    <td>{test_name.replace('_', ' ').title()}</td>
                    <td>{results['status']}</td>
                    <td>{results['passed']}</td>
                    <td>{results['failed']}</td>
                    <td><a href="{results['log_file']}">{results['log_file']}</a></td>
                </tr>
            """
        
        # Generate final HTML
        html_content = html_template.format(
            timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            total_tests=self.summary['total_tests'],
            passed_tests=self.summary['passed_tests'],
            failed_tests=self.summary['failed_tests'],
            success_rate=self.summary['success_rate'],
            test_rows=test_rows
        )
        
        # Save HTML report
        report_file = os.path.join(self.results_dir, 'test-report.html')
        with open(report_file, 'w') as f:
            f.write(html_content)
        
        print(f"HTML report generated: {report_file}")
    
    def generate_json_report(self):
        """Generate JSON test report for automation"""
        report_data = {
            'timestamp': datetime.now().isoformat(),
            'summary': self.summary,
            'test_results': self.test_results
        }
        
        report_file = os.path.join(self.results_dir, 'test-report.json')
        with open(report_file, 'w') as f:
            json.dump(report_data, f, indent=2)
        
        print(f"JSON report generated: {report_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate test report')
    parser.add_argument('--results-dir', required=True, help='Directory containing test results')
    args = parser.parse_args()
    
    generator = TestReportGenerator(args.results_dir)
    generator.parse_test_results()
    generator.generate_html_report()
    generator.generate_json_report()
    
    print(f"\nTest Summary:")
    print(f"Total Tests: {generator.summary['total_tests']}")
    print(f"Passed: {generator.summary['passed_tests']}")
    print(f"Failed: {generator.summary['failed_tests']}")
    print(f"Success Rate: {generator.summary['success_rate']:.1f}%")
```

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Review Schedule**: Before each implementation  
**Document Owner**: Cisco Security Testing Team
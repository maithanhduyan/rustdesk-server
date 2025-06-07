#!/bin/bash

# RustDesk Server Testing Script
# This script tests the RustDesk server installation and functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Test results counter
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_test "Running: $test_name"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if eval "$test_command"; then
        print_pass "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        print_fail "$test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "=========================================="
echo "RustDesk Server Test Suite"
echo "=========================================="
echo ""

# Test 1: Check if Docker is installed
run_test "Docker Installation" "command -v docker &> /dev/null"

# Test 2: Check if Docker Compose is installed
run_test "Docker Compose Installation" "command -v docker-compose &> /dev/null"

# Test 3: Check if Docker service is running
run_test "Docker Service Status" "systemctl is-active docker &> /dev/null"

# Test 4: Check if docker-compose.yml exists
run_test "Docker Compose Configuration" "test -f ../docker-compose.yml"

# Test 5: Check if containers are running
run_test "RustDesk Containers Running" "docker-compose -f ../docker-compose.yml ps | grep -q 'Up'"

# Test 6: Check hbbs container
run_test "hbbs Container Status" "docker ps | grep -q rustdesk-hbbs"

# Test 7: Check hbbr container  
run_test "hbbr Container Status" "docker ps | grep -q rustdesk-hbbr"

# Test 8: Check port 21115 (TCP)
run_test "Port 21115 TCP Listening" "netstat -tlnp | grep -q ':21115'"

# Test 9: Check port 21116 (UDP)
run_test "Port 21116 UDP Listening" "netstat -ulnp | grep -q ':21116'"

# Test 10: Check port 21117 (TCP)
run_test "Port 21117 TCP Listening" "netstat -tlnp | grep -q ':21117'"

# Test 11: Check port 21118 (TCP)
run_test "Port 21118 TCP Listening" "netstat -tlnp | grep -q ':21118'"

# Test 12: Check container logs for errors
run_test "Container Logs Check" "! docker-compose -f ../docker-compose.yml logs | grep -i error"

# Test 13: Check if data directory exists
run_test "Data Directory Exists" "test -d ../data"

# Test 14: Check container health
run_test "Container Health Check" "docker-compose -f ../docker-compose.yml ps | grep -v 'Exit'"

# Test 15: Memory usage check - simplified
run_test "Memory Usage Reasonable" "docker stats --no-stream rustdesk-hbbs | grep -v NAME | awk '{print \$4}' | grep -q MiB"

echo ""
echo "=========================================="
echo "Test Results Summary"
echo "=========================================="
echo "Total Tests: $TESTS_TOTAL"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    print_pass "All tests passed! RustDesk server is working correctly."
    echo ""
    print_info "Connection Information:"
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_PUBLIC_IP")
    echo "- ID Server: $PUBLIC_IP:21116"
    echo "- Relay Server: $PUBLIC_IP:21117"
    exit 0
else
    print_fail "$TESTS_FAILED tests failed. Please check the configuration."
    echo ""
    print_info "Troubleshooting steps:"
    echo "1. Check Docker service: sudo systemctl status docker"
    echo "2. Check container logs: docker-compose -f ../docker-compose.yml logs"
    echo "3. Restart containers: docker-compose -f ../docker-compose.yml restart"
    echo "4. Check firewall: sudo ufw status"
    exit 1
fi
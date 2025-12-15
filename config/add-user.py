#!/usr/bin/env python3
"""
LA Referencia - User Management Script

Add users to the users.properties file with BCrypt password encoding.

Usage:
    Interactive mode:
        python3 add-user.py

    Command line mode:
        python3 add-user.py <username> <password> [ROLE_ADMIN] [ROLE_USER] ...

Requirements:
    pip install bcrypt

Examples:
    python3 add-user.py                           # Interactive mode
    python3 add-user.py admin mypassword ROLE_ADMIN
    python3 add-user.py operator secret123 ROLE_ADMIN ROLE_USER
"""

import sys
import os
import getpass

try:
    import bcrypt
except ImportError:
    print("Error: bcrypt module not found.")
    print("Install it with: pip install bcrypt")
    sys.exit(1)

# Default path to users file (relative to script location)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_USERS_FILE = os.path.join(SCRIPT_DIR, "users.properties")

def hash_password(password: str) -> str:
    """Generate BCrypt hash for a password.
    Uses $2a$ prefix for compatibility with Java BCryptPasswordEncoder.
    """
    salt = bcrypt.gensalt(rounds=10, prefix=b'2a')
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def load_existing_users(filepath: str) -> set:
    """Load existing usernames from the users file."""
    users = set()
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    username = line.split('=')[0].strip()
                    if username:
                        users.add(username)
    return users

def add_user(filepath: str, username: str, password: str, roles: list) -> bool:
    """Add a new user to the users file."""
    # Validate inputs
    if not username:
        print("Error: Username cannot be empty")
        return False
    
    if not password:
        print("Error: Password cannot be empty")
        return False
    
    if not roles:
        print("Error: At least one role is required")
        return False
    
    # Check for existing user
    existing_users = load_existing_users(filepath)
    if username in existing_users:
        print(f"Error: User '{username}' already exists")
        return False
    
    # Validate roles
    valid_roles = ['ROLE_ADMIN', 'ROLE_USER']
    for role in roles:
        if role not in valid_roles:
            print(f"Warning: '{role}' is not a standard role. Standard roles are: {valid_roles}")
    
    # Generate BCrypt hash
    password_hash = hash_password(password)
    
    # Create user line
    roles_str = ','.join(roles)
    user_line = f"{username}={password_hash},{roles_str}\n"
    
    # Append to file
    with open(filepath, 'a') as f:
        f.write(user_line)
    
    print(f"Successfully added user '{username}' with roles: {roles}")
    return True

def interactive_mode(filepath: str):
    """Run in interactive mode, prompting for user input."""
    print("=" * 60)
    print("LA Referencia - Add New User")
    print("=" * 60)
    print(f"Users file: {filepath}")
    print()
    
    # Get username
    username = input("Username: ").strip()
    
    # Get password (hidden input)
    password = getpass.getpass("Password: ")
    password_confirm = getpass.getpass("Confirm password: ")
    
    if password != password_confirm:
        print("Error: Passwords do not match")
        return False
    
    # Get roles
    print("\nAvailable roles: ROLE_ADMIN, ROLE_USER")
    roles_input = input("Roles (comma-separated, default: ROLE_ADMIN): ").strip()
    
    if not roles_input:
        roles = ['ROLE_ADMIN']
    else:
        roles = [r.strip().upper() for r in roles_input.split(',')]
        # Ensure ROLE_ prefix
        roles = [r if r.startswith('ROLE_') else f'ROLE_{r}' for r in roles]
    
    print()
    return add_user(filepath, username, password, roles)

def cli_mode(filepath: str, args: list):
    """Run in command line mode with provided arguments."""
    if len(args) < 2:
        print("Error: Username and password are required")
        print("Usage: python3 add-user.py <username> <password> [ROLE_ADMIN] [ROLE_USER] ...")
        return False
    
    username = args[0]
    password = args[1]
    roles = args[2:] if len(args) > 2 else ['ROLE_ADMIN']
    
    return add_user(filepath, username, password, roles)

def main():
    # Determine users file path
    users_file = os.environ.get('USERS_FILE', DEFAULT_USERS_FILE)
    
    # Check if file exists, create with header if not
    if not os.path.exists(users_file):
        print(f"Creating new users file: {users_file}")
        with open(users_file, 'w') as f:
            f.write("# LA Referencia Users File\n")
            f.write("# Format: username=bcrypt_password,ROLE_1,ROLE_2\n")
            f.write("#\n")
    
    if len(sys.argv) > 1:
        # Command line mode
        success = cli_mode(users_file, sys.argv[1:])
    else:
        # Interactive mode
        success = interactive_mode(users_file)
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()

# MyApp - OAuth2 Protected Application

A Docker-based web application with Google OAuth2 authentication using OAuth2 Proxy as a gatekeeper. Only authenticated users can access the application.

## Project Overview

This project demonstrates a secure web application architecture where:
- **Webapp**: A simple Go web server that displays a "Hello, World!" page with a logout button
- **OAuth2 Proxy**: Acts as a reverse proxy/gatekeeper that enforces Google authentication before allowing access to the webapp

## Architecture

```
User → OAuth2 Proxy (Port 4180) → Webapp (Port 8080)
        ↓
    Google OAuth2
```

## Prerequisites

- Docker
- Docker Compose
- Google OAuth2 credentials (Client ID and Client Secret)

## Files

- **Dockerfile**: Builds the Go web application
- **docker-compose.yaml**: Single instance setup for development
- **test_app.yaml**: Multi-instance test setup with two proxy/app pairs on ports 4180 and 4181

## Setup: Create Google Cloud Credentials

Google needs to know which application is asking for permission to log users in.

### Step 1: Create a Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Click the project dropdown at the top
3. Select **New Project**
4. Give it a name like "SSO-Demo-Class"

### Step 2: Configure OAuth Consent Screen

1. Navigate to **APIs & Services** > **OAuth consent screen**
2. Choose **External** (unless you are part of a managed Google Workspace) and click **Create**
3. Fill in the following:
   - **App name**: e.g., "Student Proxy Demo"
   - **User support email**: Your email address
4. Skip the "Scopes" section for now by clicking **Save and Continue**
5. **Crucial for Testing**: In the "Test users" section, add your own email address and any student emails that will be testing the login

### Step 3: Create OAuth Client ID

1. Go to **APIs & Services** > **Credentials**
2. Click **+ Create Credentials** and select **OAuth client ID**
3. Select **Web application** as the type
4. Under **Authorized redirect URIs**, add exactly: `http://localhost:4180/oauth2/callback`
5. Click **Create** to save
6. Copy the **Client ID** and **Client Secret** that appear in the pop-up

### Step 4: Update Your Configuration

Use the Client ID and Client Secret from Step 3 when configuring your Docker Compose files (see Quick Start section below).

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Myapp
```

### 2. Update OAuth2 Credentials (Optional)

Edit `docker-compose.yaml` or `test_app.yaml` and replace the following with your own Google OAuth2 credentials:
- `OAUTH2_PROXY_CLIENT_ID`
- `OAUTH2_PROXY_CLIENT_SECRET`

### 3. Run with Docker Compose

**For single instance development:**
```bash
docker-compose up --build
```

**For testing with multiple instances:**
```bash
docker-compose -f test_app.yaml up --build
```

### 4. Access the Application

- **Test Instance 1**: http://localhost:4180
- **Test Instance 2**: http://localhost:4181

## Configuration

### Environment Variables

#### Webapp
- `REDIRECT_URL`: URL to redirect to after logout (default: `http://localhost:4180`)

#### OAuth2 Proxy
- `OAUTH2_PROXY_PROVIDER`: OAuth provider (set to "google")
- `OAUTH2_PROXY_CLIENT_ID`: Google OAuth Client ID
- `OAUTH2_PROXY_CLIENT_SECRET`: Google OAuth Client Secret
- `OAUTH2_PROXY_REDIRECT_URL`: OAuth callback URL
- `OAUTH2_PROXY_UPSTREAMS`: Upstream service URL to protect
- `OAUTH2_PROXY_EMAIL_DOMAINS`: Allowed email domains ("*" allows all)
- `OAUTH2_PROXY_COOKIE_SECRET`: Secret key for session cookies
- `OAUTH2_PROXY_COOKIE_SECURE`: Enable secure cookies (false for HTTP)
- `OAUTH2_PROXY_COOKIE_SAMESITE`: SameSite cookie attribute

## Security Notes

⚠️ **Important**: The current configuration contains hardcoded credentials and is meant for development/testing only.

**For production deployment:**
- Use environment variables or secrets management for OAuth credentials
- Set `OAUTH2_PROXY_COOKIE_SECURE: "true"` (requires HTTPS)
- Change `OAUTH2_PROXY_EMAIL_DOMAINS` to restrict access to specific domains
- Use a proper cookie secret (longer and more random)
- Enable HTTPS/TLS

## Usage Flow

1. User navigates to http://localhost:4180
2. OAuth2 Proxy redirects to Google login (if not authenticated)
3. User authenticates with Google
4. OAuth2 Proxy redirects back to the application
5. Webapp displays the protected content with a logout button
6. User can click logout to clear authentication

## Troubleshooting

**Localhost redirect issues**: Ensure `REDIRECT_URL` and `OAUTH2_PROXY_REDIRECT_URL` match your access URL

**OAuth errors**: Verify that:
- Client ID and Client Secret are correct
- Redirect URL is registered in your Google OAuth app
- Network connectivity to Google OAuth endpoints


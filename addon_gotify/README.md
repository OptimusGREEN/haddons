
# README.md
# Home Assistant Add-on: Gotify Server

A simple server for sending and receiving messages in real-time per WebSocket. Gotify is a self-hosted push notification service that allows you to send messages via a REST-API and receive them in real-time through WebSocket connections.

## Installation

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on Store**.
2. Click the 3-dots menu at upper right **...** -> **Repositories** and add this repository URL.
3. Find the "Gotify Server" add-on and click it.
4. Click on the "INSTALL" button.

## How to use

1. Start the add-on.
2. Check the add-on log output to see the result.
3. Access the Gotify web interface at `http://homeassistant.local:8080` or through the Home Assistant ingress panel.
4. Login with the configured admin credentials (default: admin/admin).
5. Create applications and get tokens for sending notifications.

## Configuration

Add-on configuration:

```yaml
log_level: info
admin_user: admin
admin_pass: admin
database_path: /data/gotify.db
upload_dir: /data/uploads
registration: false
```

### Option: `log_level` (required)

The log level for Gotify server.

### Option: `admin_user` (required)

The default admin username for Gotify.

### Option: `admin_pass` (required)

The default admin password for Gotify.

### Option: `database_path` (required)

Path to the SQLite database file.

### Option: `upload_dir` (required)

Directory for uploaded images.

### Option: `registration` (required)

Enable or disable user registration.

## Sending Messages

You can send messages to Gotify using the REST API:

```bash
curl -X POST "http://homeassistant.local:8080/message?token=<apptoken>" \
     -F "title=my title" \
     -F "message=my message" \
     -F "priority=5"
```

Or from Home Assistant using the REST command:

```yaml
rest_command:
  gotify_notification:
    url: "http://localhost:8080/message"
    method: POST
    headers:
      X-Gotify-Key: "YOUR_APP_TOKEN"
    payload: |
      {
        "title": "{{ title }}",
        "message": "{{ message }}",
        "priority": {{ priority | default(5) }}
      }
```

## Network

This add-on exposes port 8080 for the Gotify web interface and API.

## Storage

The add-on stores its data in the `/data` directory, which is persistent across restarts.

## Support

In case you've found a bug, please [open an issue on GitHub](https://github.com/gotify/server/issues).

---

# CHANGELOG.md
# Changelog

## [2.4.0] - 2024-01-15

### Added
- Initial release of Gotify Home Assistant Add-on
- Support for all Home Assistant architectures
- Configurable admin credentials
- Persistent data storage
- Home Assistant ingress support
- Web interface access

### Features
- Real-time message delivery via WebSocket
- REST API for sending messages
- User and application management
- Message priorities and images
- SQLite database storage
- Optional user registration

---

# DOCS.md
# Home Assistant Add-on: Gotify Server

Gotify is a simple server for sending and receiving messages in real-time per WebSocket. It's perfect for self-hosted push notifications that integrate seamlessly with Home Assistant.

## Features

- **Real-time notifications**: Receive messages instantly via WebSocket connections
- **REST API**: Send messages programmatically from Home Assistant or other services
- **Web interface**: Manage applications, users, and view message history
- **Multiple clients**: Android app, CLI tools, and web interface
- **Message priorities**: Set different priority levels for messages
- **Image support**: Attach images to your notifications
- **User management**: Create multiple users and applications
- **Persistent storage**: All data stored in Home Assistant's data directory

## Getting Started

1. **Install the add-on** from the Home Assistant Add-on Store
2. **Configure** the admin credentials and other settings
3. **Start** the add-on
4. **Access** the web interface through Home Assistant's ingress or at port 8080
5. **Create applications** and get tokens for sending messages

## Integration with Home Assistant

### Using REST Command

Add this to your `configuration.yaml`:

```yaml
rest_command:
  send_gotify_notification:
    url: "http://localhost:8080/message"
    method: POST
    headers:
      X-Gotify-Key: "YOUR_APP_TOKEN_HERE"
    payload: |
      {
        "title": "{{ title }}",
        "message": "{{ message }}",
        "priority": {{ priority | default(5) }}
      }
```

### Using in Automations

```yaml
automation:
  - alias: "Door Open Notification"
    trigger:
      platform: state
      entity_id: binary_sensor.front_door
      to: "on"
    action:
      service: rest_command.send_gotify_notification
      data:
        title: "Security Alert"
        message: "Front door has been opened!"
        priority: 8
```

## Mobile App

Download the Gotify Android app from:
- [Google Play Store](https://play.google.com/store/apps/details?id=com.github.gotify)
- [F-Droid](https://f-droid.org/packages/com.github.gotify/)
- [GitHub Releases](https://github.com/gotify/android/releases)

Configure the app with:
- **Server URL**: `http://your-home-assistant-ip:8080`
- **Client Token**: Generate from the Gotify web interface

## Security Considerations

- Change the default admin password immediately after installation
- Consider using HTTPS if exposing externally (requires reverse proxy)
- Regularly update the add-on to get security patches
- Use strong, unique tokens for applications

## Troubleshooting

### Common Issues

1. **Can't access web interface**
   - Check if the add-on is running
   - Verify port 8080 is not blocked
   - Try accessing via Home Assistant ingress

2. **Messages not sending**
   - Verify the application token is correct
   - Check the Gotify logs in Home Assistant
   - Ensure the API endpoint URL is correct

3. **Database errors**
   - Check file permissions in `/data` directory
   - Restart the add-on
   - Check available disk space

### Logs

Check the add-on logs in Home Assistant for detailed error messages and debugging information.

## Advanced Configuration

### Environment Variables

The add-on supports additional configuration through environment variables. Check the Gotify documentation for all available options.

### Plugins

Gotify supports plugins for extended functionality. Place plugin files in `/data/plugins/` directory.

## API Reference

### Send Message

```http
POST /message?token=<apptoken>
Content-Type: application/json

{
  "title": "Message Title",
  "message": "Message content",
  "priority": 5
}
```

### Get Messages

```http
GET /message?token=<clienttoken>
```

For complete API documentation, visit the [Gotify API docs](https://gotify.net/docs/swagger-docs).

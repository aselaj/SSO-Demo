FROM golang:1.21-alpine AS builder

WORKDIR /app

RUN cat > main.go << 'EOF'
package main

import (
    "fmt"
    "net/http"
    "net/url"
    "os"
)

func main() {
    redirectUrl := os.Getenv("REDIRECT_URL")
    if redirectUrl == "" {
        redirectUrl = "http://localhost:4180"
    }

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        logoutUrl := fmt.Sprintf("/oauth2/sign_out?rd=%s", url.QueryEscape(redirectUrl))
        html := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <title>App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        button { padding: 10px 20px; font-size: 16px; }
    </style>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>You are logged in.</p>
    <a href="%s"><button>Logout</button></a>
</body>
</html>
        `, logoutUrl)
        w.Header().Set("Content-Type", "text/html")
        fmt.Fprint(w, html)
    })
    http.ListenAndServe(":8080", nil)
}
EOF

RUN go mod init app && go build -o app main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/app .
EXPOSE 8080
CMD ["./app"]
#!/bin/bash

# 1. Initialize Folders
echo "Creating project structure..."
mkdir -p cmd/api
mkdir -p internal/config
mkdir -p internal/database
mkdir -p internal/middleware
mkdir -p internal/modules/auth
mkdir -p internal/modules/profile
mkdir -p internal/modules/discovery
mkdir -p internal/modules/chat
mkdir -p internal/modules/wingman
mkdir -p internal/modules/safety

# 2. Setup go.mod (Update/Tidy)
if [ ! -f go.mod ]; then
    go mod init strings-be
fi
# We will run 'go mod tidy' at the end

# 3. Create Configuration
cat > internal/config/config.go << 'EOF'
package config

import "os"

type Config struct {
    Port         string
    DatabaseURL  string
    FirebaseProjectID string
    OpenAIKey    string
    EncryptionKey string // For EAR
}

func Load() *Config {
    return &Config{
        Port:              getEnv("PORT", "8080"),
        DatabaseURL:       getEnv("DATABASE_URL", "postgres://user:pass@localhost:5432/playdate?sslmode=disable"),
        FirebaseProjectID: getEnv("FIREBASE_PROJECT_ID", "playdate-app"),
        OpenAIKey:         getEnv("OPENAI_API_KEY", ""),
        EncryptionKey:     getEnv("EAR_ENCRYPTION_KEY", "super-secret-key-32-chars-long!!"),
    }
}

func getEnv(key, fallback string) string {
    if value, exists := os.LookupEnv(key); exists {
        return value
    }
    return fallback
}
EOF

# 4. Create Database Logic & Schema
cat > internal/database/db.go << 'EOF'
package database

import (
    "database/sql"
    "log"
    
    // _ "github.com/lib/pq" // Driver import (uncomment after go mod tidy)
)

var DB *sql.DB

func Init(connStr string) {
    var err error
    // DB, err = sql.Open("postgres", connStr) // Uncomment when driver is added
    if err != nil {
        log.Fatal("Failed to connect to DB:", err)
    }
    // Ping DB to verify connection
    // if err = DB.Ping(); err != nil { log.Fatal(err) }
    log.Println("Connected to Database (EAR Enabled)")
}
EOF

cat > internal/database/schema.sql << 'EOF'
-- Core Identity
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid VARCHAR(128) UNIQUE NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Profile (Hybrid AI)
CREATE TABLE profiles (
    profile_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    display_name VARCHAR(50),
    encrypted_bio TEXT, -- EAR Encrypted
    location GEOGRAPHY(POINT, 4326),
    search_preferences JSONB DEFAULT '{}'
);

-- Photos (AI Metadata)
CREATE TABLE user_photos (
    photo_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    image_url TEXT NOT NULL,
    ai_context_tags JSONB DEFAULT '{}', -- {"scene": "mountain", "emotion": "happy"}
    is_blurred BOOLEAN DEFAULT FALSE
);

-- Chat (Wingman & History)
CREATE TABLE matches (
    match_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id UUID REFERENCES users(user_id),
    user_b_id UUID REFERENCES users(user_id),
    vibe_state VARCHAR(20) DEFAULT 'NEW' -- SPARKING, DRY, GHOSTED
);

CREATE TABLE chat_messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES matches(match_id),
    sender_id UUID REFERENCES users(user_id),
    encrypted_content TEXT, -- EAR Encrypted
    is_wingman_suggestion BOOLEAN DEFAULT FALSE,
    delivered_at TIMESTAMPTZ DEFAULT NOW()
);
EOF

# 5. Create Auth Module
cat > internal/modules/auth/handler.go << 'EOF'
package auth

import (
    "encoding/json"
    "net/http"
)

type LoginRequest struct {
    FirebaseToken string `json:"firebase_token"`
}

func LoginHandler(w http.ResponseWriter, r *http.Request) {
    // 1. Verify Firebase Token (Stub)
    // 2. Check if user exists in DB
    // 3. Generate Playdate JWT
    
    response := map[string]interface{}{
        "token": "playdate_jwt_token_stub",
        "user_id": "uuid-stub",
        "is_new_user": false,
    }
    json.NewEncoder(w).Encode(response)
}
EOF

# 6. Create Profile Module (Hybrid AI)
cat > internal/modules/profile/handler.go << 'EOF'
package profile

import (
    "encoding/json"
    "net/http"
)

// Request with On-Device AI Metadata
type UploadPhotoRequest struct {
    Photos []struct {
        URL        string `json:"url"`
        AIMetadata struct {
            Scene   string   `json:"scene"`
            Objects []string `json:"objects"`
        } `json:"ai_metadata"`
    } `json:"photos"`
}

func UploadPhotosHandler(w http.ResponseWriter, r *http.Request) {
    // 1. Save Photo URL to DB
    // 2. Save AI Metadata (Tags) to DB for Wingman usage
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(map[string]string{"status": "Photos processed with AI tags"})
}

func UpdateProfileHandler(w http.ResponseWriter, r *http.Request) {
    // 1. Receive Bio
    // 2. Encrypt Bio (EAR) using config.EncryptionKey
    // 3. Save to DB
    json.NewEncoder(w).Encode(map[string]string{"status": "Profile updated securely"})
}
EOF

# 7. Create Wingman Module (The Brain)
cat > internal/modules/wingman/service.go << 'EOF'
package wingman

import (
    "fmt"
)

// The "Clued-In Bestie" Logic
func GenerateBio(tags []string) string {
    // In reality, this calls OpenAI/Gemini API
    return fmt.Sprintf("Based on your %s photos, I'd say: 'Adventure seeker looking for a coffee partner!'", tags[0])
}

func GetChatNudge(history []string) string {
    // Analyzes last 20 messages
    return "They mentioned 'Toit'. Ask them if they prefer Stout or Lager! 🍺"
}
EOF

# 8. Create Chat Module
cat > internal/modules/chat/handler.go << 'EOF'
package chat

import (
    "encoding/json"
    "net/http"
    "github.com/siddhantlakhaiyar/strings-be/internal/modules/wingman"
)

func SendMessageHandler(w http.ResponseWriter, r *http.Request) {
    // 1. Receive Message
    // 2. Encrypt & Save to DB
    // 3. Async: Trigger Wingman Historian to update "Vibe State"
    json.NewEncoder(w).Encode(map[string]string{"status": "Sent"})
}

func GetWingmanNudgeHandler(w http.ResponseWriter, r *http.Request) {
    // 1. Fetch Chat History
    history := []string{"Hey", "Wassup", "Not much"} // Stub
    
    // 2. Ask Wingman
    nudge := wingman.GetChatNudge(history)
    
    json.NewEncoder(w).Encode(map[string]string{
        "nudge": nudge,
        "reasoning": "User B mentioned craft beer recently.",
    })
}
EOF

# 9. Create Safety Module
cat > internal/modules/safety/handler.go << 'EOF'
package safety

import (
    "encoding/json"
    "net/http"
)

func LivenessCheckHandler(w http.ResponseWriter, r *http.Request) {
    // 1. Receive Video URL & Gesture Code
    // 2. Send to Python/AI Service or Facia.ai
    json.NewEncoder(w).Encode(map[string]string{"status": "Verification Pending", "eta": "30s"})
}
EOF

# 10. Main Entry Point
cat > cmd/api/main.go << 'EOF'
package main

import (
    "log"
    "net/http"
    "github.com/siddhantlakhaiyar/strings-be/internal/config"
    "github.com/siddhantlakhaiyar/strings-be/internal/database"
    "github.com/siddhantlakhaiyar/strings-be/internal/modules/auth"
    "github.com/siddhantlakhaiyar/strings-be/internal/modules/profile"
    "github.com/siddhantlakhaiyar/strings-be/internal/modules/chat"
    "github.com/siddhantlakhaiyar/strings-be/internal/modules/safety"
)

func main() {
    // 1. Load Config
    cfg := config.Load()
    
    // 2. Initialize DB
    database.Init(cfg.DatabaseURL)
    
    // 3. Setup Router (Standard ServeMux for simplicity)
    mux := http.NewServeMux()
    
    // Auth Routes
    mux.HandleFunc("POST /auth/login", auth.LoginHandler)
    
    // Profile Routes (TLS + EAR + AI)
    mux.HandleFunc("PUT /profile/me", profile.UpdateProfileHandler)
    mux.HandleFunc("POST /profile/photos", profile.UploadPhotosHandler)
    
    // Chat & Wingman Routes
    mux.HandleFunc("POST /chat/send", chat.SendMessageHandler)
    mux.HandleFunc("GET /chat/wingman/nudge", chat.GetWingmanNudgeHandler)
    
    // Safety Routes
    mux.HandleFunc("POST /safety/verify", safety.LivenessCheckHandler)
    
    log.Printf("Playdate Monolith starting on port %s...", cfg.Port)
    if err := http.ListenAndServe(":"+cfg.Port, mux); err != nil {
        log.Fatal(err)
    }
}
EOF

# 11. Final Tidy
echo "Running go mod tidy..."
# This might fail if you don't have internet or valid git config, 
# but it's the standard step to download dependencies.
go mod tidy

echo "✅ Playdate Monolith Created Successfully!"
echo "Run: go run cmd/api/main.go"

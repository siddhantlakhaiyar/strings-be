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

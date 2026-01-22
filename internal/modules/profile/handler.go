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

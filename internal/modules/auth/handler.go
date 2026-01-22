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

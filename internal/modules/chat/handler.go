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

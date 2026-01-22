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

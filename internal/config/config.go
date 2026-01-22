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

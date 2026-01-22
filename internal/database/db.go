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

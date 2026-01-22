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

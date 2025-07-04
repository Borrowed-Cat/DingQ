-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create SVG icons table
CREATE TABLE IF NOT EXISTS svg_icons (
    id SERIAL PRIMARY KEY,
    icon_name VARCHAR(255) NOT NULL UNIQUE,
    svg_path VARCHAR(500) NOT NULL,
    vector_features vector(512), -- CNN feature vector
    category VARCHAR(100),
    description TEXT,
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user sketches table for ML performance improvement
CREATE TABLE IF NOT EXISTS user_sketches (
    id SERIAL PRIMARY KEY,
    user_ip VARCHAR(45), -- IPv4/IPv6 지원
    sketch_data BYTEA NOT NULL, -- 이미지 바이너리 데이터
    original_filename VARCHAR(255),
    content_type VARCHAR(100),
    file_size INTEGER,
    search_results JSONB, -- 검색 결과 저장
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);

-- Create index for vector similarity search
CREATE INDEX IF NOT EXISTS idx_svg_icons_vector 
ON svg_icons USING ivfflat (vector_features vector_cosine_ops);

-- Create index for category search
CREATE INDEX IF NOT EXISTS idx_svg_icons_category 
ON svg_icons(category);

-- Create indexes for user sketches
CREATE INDEX IF NOT EXISTS idx_user_sketches_user_ip 
ON user_sketches(user_ip);

CREATE INDEX IF NOT EXISTS idx_user_sketches_created_at 
ON user_sketches(created_at);

CREATE INDEX IF NOT EXISTS idx_user_sketches_search_results 
ON user_sketches USING gin (search_results);

-- Create function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
CREATE TRIGGER update_svg_icons_updated_at 
    BEFORE UPDATE ON svg_icons 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data (251 icons placeholder)
INSERT INTO svg_icons (icon_name, svg_path, category, description) VALUES
('home', 'gs://dingq-svg-icons/home.svg', 'navigation', 'Home icon'),
('search', 'gs://dingq-svg-icons/search.svg', 'action', 'Search icon'),
('settings', 'gs://dingq-svg-icons/settings.svg', 'navigation', 'Settings icon')
ON CONFLICT (icon_name) DO NOTHING; 
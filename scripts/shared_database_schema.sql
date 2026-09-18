-- ============================================================================
-- INsitu AI Ads — Shared Database Schema for Supabase (Project: etcinnmgjflimpkpxrpo)
-- Compatible with Insitu-CRM (Zero Table Collisions, Independent Public Tables)
-- ============================================================================

-- 1. Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. users (Dedicated table for Ads platform / extension users)
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE,
    password TEXT,
    email TEXT UNIQUE,
    "firstName" TEXT,
    "lastName" TEXT,
    phone TEXT,
    role TEXT,
    "approvalStatus" TEXT,
    picture TEXT,
    "lastLogin" BIGINT,
    subscription TEXT,
    "totalTokensUsed" INTEGER DEFAULT 0,
    "usageLimit" INTEGER DEFAULT 10000,
    "usageHistory" TEXT,
    "brandProfile" TEXT,
    "brandProfiles" TEXT DEFAULT '[]',
    "freeTrialsUsed" INTEGER DEFAULT 0,
    "recoveryCode" TEXT,
    "recoveryCodeExpiry" BIGINT,
    "linkedGoogleAds" TEXT,
    "linkedSearchConsole" TEXT,
    "savedVoices" TEXT DEFAULT '[]',
    "is_deleted" BOOLEAN DEFAULT false,
    "deleted_at" BIGINT,
    "extension_session_token" TEXT,
    "extension_token_expires" TIMESTAMP WITH TIME ZONE,
    "organization_id" TEXT
);

-- 3. settings
CREATE TABLE IF NOT EXISTS public.settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    data TEXT
);

-- 4. blog_posts
CREATE TABLE IF NOT EXISTS public.blog_posts (
    id TEXT PRIMARY KEY,
    title TEXT,
    slug TEXT UNIQUE,
    content TEXT,
    excerpt TEXT,
    "authorId" TEXT,
    "authorName" TEXT,
    "authorPicture" TEXT,
    "publishedAt" BIGINT,
    "updatedAt" BIGINT,
    status TEXT DEFAULT 'draft',
    category TEXT,
    tags TEXT,
    "featuredImage" TEXT,
    "metaTitle" TEXT,
    "metaDescription" TEXT,
    keywords TEXT,
    "readingTime" TEXT,
    "is_deleted" BOOLEAN DEFAULT false,
    "deleted_at" BIGINT
);

-- 5. notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at BIGINT NOT NULL,
    cta_url TEXT,
    image_url TEXT,
    video_url TEXT,
    "is_deleted" BOOLEAN DEFAULT false,
    "deleted_at" BIGINT
);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications (user_id);

-- 6. engagement_events
CREATE TABLE IF NOT EXISTS public.engagement_events (
    id TEXT PRIMARY KEY,
    notification_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    timestamp BIGINT NOT NULL,
    metadata JSONB,
    "is_deleted" BOOLEAN DEFAULT false,
    "deleted_at" BIGINT
);
CREATE INDEX IF NOT EXISTS idx_engagement_user_id ON public.engagement_events (user_id);

-- 7. seo_history & cache
CREATE TABLE IF NOT EXISTS public.seo_history (
    id SERIAL PRIMARY KEY,
    domain TEXT NOT NULL,
    result TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_seo_history_domain ON public.seo_history (domain);

CREATE TABLE IF NOT EXISTS public.ai_visual_cache (
    id SERIAL PRIMARY KEY,
    hash VARCHAR(255) UNIQUE NOT NULL,
    result JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.pagespeed_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    url TEXT NOT NULL,
    strategy TEXT NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_pagespeed_url_strategy ON public.pagespeed_cache(url, strategy);

-- 8. competitor intelligence
CREATE TABLE IF NOT EXISTS public.competitor_tracks (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    brand_name TEXT NOT NULL,
    search_query TEXT NOT NULL,
    networks TEXT[] DEFAULT '{search,tech,seo}',
    country TEXT DEFAULT 'ALL',
    is_active BOOLEAN DEFAULT true,
    notify_email BOOLEAN DEFAULT true,
    notify_inapp BOOLEAN DEFAULT true,
    created_at BIGINT,
    last_checked_at BIGINT,
    total_signals_found INTEGER DEFAULT 0,
    "is_deleted" BOOLEAN DEFAULT false,
    "deleted_at" BIGINT,
    UNIQUE(user_id, brand_name)
);
CREATE INDEX IF NOT EXISTS idx_competitor_tracks_user ON public.competitor_tracks (user_id);

CREATE TABLE IF NOT EXISTS public.competitor_signals (
    id TEXT PRIMARY KEY,
    track_id TEXT NOT NULL REFERENCES public.competitor_tracks(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    source TEXT,
    title TEXT,
    description TEXT,
    url TEXT,
    relevance_score INTEGER DEFAULT 0,
    detected_at BIGINT,
    is_new BOOLEAN DEFAULT true,
    raw_data JSONB,
    "is_deleted" BOOLEAN DEFAULT false,
    "deleted_at" BIGINT,
    UNIQUE(track_id, url, type)
);
CREATE INDEX IF NOT EXISTS idx_competitor_signals_track ON public.competitor_signals (track_id);

-- 9. AI Feedback Loop & Logs
CREATE TABLE IF NOT EXISTS public.ai_feedback (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    feature VARCHAR(50) NOT NULL,
    prompt_context TEXT,
    ai_response JSONB,
    feedback_type VARCHAR(20) NOT NULL,
    feedback_reason VARCHAR(100),
    rating INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.ai_prompt_rules (
    id SERIAL PRIMARY KEY,
    rule_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    feature VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);
CREATE INDEX IF NOT EXISTS idx_ai_prompt_rules_feature ON public.ai_prompt_rules (feature);

CREATE TABLE IF NOT EXISTS public.market_trends (
    id SERIAL PRIMARY KEY,
    month_key VARCHAR(10) UNIQUE,
    findings JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.ai_technical_logs (
    id SERIAL PRIMARY KEY,
    feature VARCHAR(50) NOT NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    request_context JSONB,
    severity VARCHAR(20) DEFAULT 'error',
    user_id VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.ai_performance_feedback (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    feature VARCHAR(100) NOT NULL,
    context JSONB,
    improved_metric VARCHAR(50),
    success_story TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Leads & Audit History
CREATE TABLE IF NOT EXISTS public.leads (
    id TEXT PRIMARY KEY,
    role TEXT,
    budget TEXT,
    goals TEXT,
    email TEXT,
    name TEXT,
    website TEXT,
    notes TEXT,
    "createdAt" BIGINT,
    status TEXT,
    "is_deleted" BOOLEAN DEFAULT false,
    "deleted_at" BIGINT
);

CREATE TABLE IF NOT EXISTS public.history (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    type TEXT NOT NULL,
    query JSONB NOT NULL,
    result JSONB NOT NULL,
    timestamp BIGINT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);
CREATE INDEX IF NOT EXISTS idx_history_user_id ON public.history (user_id);
CREATE INDEX IF NOT EXISTS idx_history_type ON public.history (type);
CREATE INDEX IF NOT EXISTS idx_history_user_timestamp ON public.history (user_id, timestamp DESC);

CREATE TABLE IF NOT EXISTS public.processed_webhook_events (
    event_id TEXT PRIMARY KEY,
    event_type TEXT,
    processed_at BIGINT NOT NULL
);

-- 11. Platform Updates & User Tools
CREATE TABLE IF NOT EXISTS public.platform_updates (
    id TEXT PRIMARY KEY,
    version TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('major','feature','fix','ai-upgrade')),
    title_es TEXT NOT NULL,
    title_en TEXT NOT NULL,
    description_es TEXT NOT NULL,
    description_en TEXT NOT NULL,
    preview_url TEXT,
    feature_tab TEXT,
    cta_url TEXT,
    email_subject_active TEXT,
    email_subject_trial TEXT,
    email_subject_expired TEXT,
    email_subject_free TEXT,
    published_at BIGINT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_by TEXT NOT NULL,
    emails_sent INTEGER DEFAULT 0,
    emails_opened INTEGER DEFAULT 0,
    reads_count INTEGER DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_platform_updates_active ON public.platform_updates (is_active, published_at);

CREATE TABLE IF NOT EXISTS public.platform_update_reads (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    update_id TEXT NOT NULL,
    read_at BIGINT NOT NULL,
    source TEXT NOT NULL,
    UNIQUE(user_id, update_id)
);
CREATE INDEX IF NOT EXISTS idx_pur_user ON public.platform_update_reads (user_id);

CREATE TABLE IF NOT EXISTS public.user_tools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    tool_name TEXT NOT NULL,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, tool_name)
);
CREATE INDEX IF NOT EXISTS idx_user_tools_user_id ON public.user_tools (user_id);

CREATE TABLE IF NOT EXISTS public.user_scripts (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    customer_id TEXT,
    brief TEXT,
    script_content TEXT NOT NULL,
    instructions TEXT,
    created_at BIGINT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);
CREATE INDEX IF NOT EXISTS idx_user_scripts_user_id ON public.user_scripts (user_id);

-- 12. Police Governance & Campaign Audit Modules
CREATE TABLE IF NOT EXISTS public.police_user_assignments (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    organization_id TEXT NOT NULL,
    client_id TEXT,
    platform_account_id TEXT,
    created_at BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_police_user_assignments_user ON public.police_user_assignments (user_id);

CREATE TABLE IF NOT EXISTS public.police_organizations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    owner_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);

CREATE TABLE IF NOT EXISTS public.police_clients (
    id TEXT PRIMARY KEY,
    organization_id TEXT NOT NULL REFERENCES public.police_organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    contact_person TEXT,
    industry TEXT,
    country TEXT,
    monthly_budget NUMERIC(12,2),
    status TEXT DEFAULT 'active',
    brand_profile_id TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);

CREATE TABLE IF NOT EXISTS public.police_integrations (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    organization_id TEXT NOT NULL REFERENCES public.police_organizations(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    sync_method TEXT DEFAULT 'scraping',
    status TEXT DEFAULT 'pending',
    access_token TEXT,
    refresh_token TEXT,
    expires_at BIGINT,
    account_id TEXT,
    account_name TEXT,
    last_synced_at BIGINT,
    next_sync_at BIGINT,
    sync_status TEXT DEFAULT 'idle',
    last_error TEXT,
    webhook_token TEXT UNIQUE,
    webhook_url TEXT,
    metadata JSONB,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    disconnected_at BIGINT,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);

CREATE TABLE IF NOT EXISTS public.police_platform_accounts (
    id TEXT PRIMARY KEY,
    client_id TEXT NOT NULL REFERENCES public.police_clients(id) ON DELETE CASCADE,
    organization_id TEXT NOT NULL REFERENCES public.police_organizations(id) ON DELETE CASCADE,
    platform TEXT NOT NULL,
    account_id TEXT NOT NULL,
    account_name TEXT,
    integration_id TEXT REFERENCES public.police_integrations(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'active',
    last_synced_at BIGINT,
    sync_status TEXT DEFAULT 'idle',
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);

CREATE TABLE IF NOT EXISTS public.police_policies (
    id TEXT PRIMARY KEY,
    organization_id TEXT NOT NULL REFERENCES public.police_organizations(id) ON DELETE CASCADE,
    client_id TEXT REFERENCES public.police_clients(id) ON DELETE CASCADE,
    platform_account_id TEXT REFERENCES public.police_platform_accounts(id) ON DELETE CASCADE,
    campaign_rules JSONB DEFAULT '[]',
    adset_rules JSONB DEFAULT '[]',
    ad_rules JSONB DEFAULT '[]',
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.police_campaigns (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    organization_id TEXT NOT NULL REFERENCES public.police_organizations(id) ON DELETE CASCADE,
    client_id TEXT NOT NULL REFERENCES public.police_clients(id) ON DELETE CASCADE,
    platform_account_id TEXT NOT NULL REFERENCES public.police_platform_accounts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    platform TEXT NOT NULL,
    budget NUMERIC(12,2) NOT NULL,
    max_budget_allowed NUMERIC(12,2) NOT NULL,
    status TEXT DEFAULT 'draft',
    nomenclature_valid BOOLEAN DEFAULT false,
    nomenclature_errors JSONB DEFAULT '[]',
    budget_valid BOOLEAN DEFAULT true,
    budget_exceeded_by NUMERIC(5,2) DEFAULT 0.0,
    country TEXT,
    channel TEXT,
    objective TEXT,
    product TEXT,
    year TEXT,
    synced_with_extension BOOLEAN DEFAULT false,
    last_synced_at BIGINT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);

CREATE TABLE IF NOT EXISTS public.police_alerts (
    id TEXT PRIMARY KEY,
    campaign_id TEXT NOT NULL REFERENCES public.police_campaigns(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    organization_id TEXT NOT NULL REFERENCES public.police_organizations(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    severity TEXT NOT NULL,
    message TEXT NOT NULL,
    budget NUMERIC(12,2),
    max_allowed NUMERIC(12,2),
    exceeded_by NUMERIC(5,2),
    is_resolved BOOLEAN DEFAULT false,
    resolved_at BIGINT,
    resolved_by TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);

CREATE TABLE IF NOT EXISTS public.police_extension_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    client_id TEXT REFERENCES public.police_clients(id) ON DELETE SET NULL,
    brand TEXT,
    activity_type TEXT NOT NULL,
    platform TEXT NOT NULL,
    campaign_name TEXT NOT NULL,
    budget NUMERIC(12,2),
    budget_type TEXT,
    start_date TEXT,
    end_date TEXT,
    objective TEXT,
    max_budget_allowed NUMERIC(12,2),
    status TEXT,
    utm_url TEXT,
    campaign_id TEXT,
    adset_id TEXT,
    ad_id TEXT,
    created_at BIGINT NOT NULL,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at BIGINT
);

-- 13. RLS — Row Level Security (Protects against direct PostgREST client tampering)
DO $$ 
DECLARE 
    t text;
    tables text[] := ARRAY[
        'users', 'history', 'leads', 'settings', 'notifications', 'blog_posts',
        'seo_history', 'competitor_tracks', 'competitor_signals', 'engagement_events', 
        'ai_visual_cache', 'ai_feedback', 'ai_prompt_rules', 'ai_technical_logs', 
        'ai_performance_feedback', 'platform_updates', 'platform_update_reads', 
        'user_scripts', 'police_organizations', 'police_policies', 'police_clients', 
        'police_integrations', 'police_platform_accounts', 'police_campaigns', 
        'police_alerts', 'police_extension_activities'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        EXECUTE format('ALTER TABLE IF EXISTS public.%I ENABLE ROW LEVEL SECURITY;', t);
    END LOOP;
END $$;

-- Explicit restrictive policies for security
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='users' AND policyname='users_deny_all_postgrest') THEN
        CREATE POLICY "users_deny_all_postgrest" ON public.users AS RESTRICTIVE
        FOR ALL TO anon, authenticated USING (false) WITH CHECK (false);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='leads' AND policyname='leads_insert_anon') THEN
        CREATE POLICY "leads_insert_anon" ON public.leads
        FOR INSERT TO anon WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='blog_posts' AND policyname='blog_posts_public_read') THEN
        CREATE POLICY "blog_posts_public_read" ON public.blog_posts
        FOR SELECT TO anon, authenticated USING (status = 'published');
    END IF;
END $$;

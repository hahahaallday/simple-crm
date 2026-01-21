-- Create customers table
CREATE TABLE public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    company_name TEXT,

    -- Address information
    country_code TEXT NOT NULL,
    region TEXT,
    city TEXT,
    postal_code TEXT,

    -- Preferences
    timezone TEXT NOT NULL DEFAULT 'UTC',
    language TEXT NOT NULL DEFAULT 'en',
    currency TEXT NOT NULL DEFAULT 'USD',

    -- Status
    status TEXT NOT NULL CHECK (status IN ('active', 'inactive', 'vip', 'blocked')) DEFAULT 'active',

    -- Custom fields (flexible JSON storage)
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Computed fields (updated by triggers/functions)
    lifetime_value NUMERIC(15, 2) DEFAULT 0.00,
    total_orders INTEGER DEFAULT 0,
    average_order_value NUMERIC(15, 2) DEFAULT 0.00,
    first_order_date TIMESTAMP WITH TIME ZONE,
    last_order_date TIMESTAMP WITH TIME ZONE,

    -- Integration fields
    external_id TEXT,
    external_platform TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Ensure unique external references
    UNIQUE(external_id, external_platform)
);

-- Create indexes for common queries
CREATE INDEX idx_customers_email ON public.customers(email);
CREATE INDEX idx_customers_country_code ON public.customers(country_code);
CREATE INDEX idx_customers_status ON public.customers(status);
CREATE INDEX idx_customers_created_at ON public.customers(created_at DESC);
CREATE INDEX idx_customers_external ON public.customers(external_id, external_platform) WHERE external_id IS NOT NULL;
CREATE INDEX idx_customers_custom_fields ON public.customers USING GIN (custom_fields);

-- Trigger to update updated_at
CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON public.customers
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Comments
COMMENT ON TABLE public.customers IS 'Customer records for cross-border ecommerce';
COMMENT ON COLUMN public.customers.custom_fields IS 'Flexible JSON storage for custom customer data';
COMMENT ON COLUMN public.customers.lifetime_value IS 'Total value of all customer orders in USD';
COMMENT ON COLUMN public.customers.external_id IS 'ID from external system (e.g., Shopify customer ID)';
COMMENT ON COLUMN public.customers.external_platform IS 'Source platform (e.g., shopify, woocommerce)';

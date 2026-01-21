-- Create tags table
CREATE TABLE public.tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    color TEXT NOT NULL DEFAULT '#3B82F6',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create customer_tags junction table
CREATE TABLE public.customer_tags (
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (customer_id, tag_id)
);

-- Create indexes
CREATE INDEX idx_tags_name ON public.tags(name);
CREATE INDEX idx_customer_tags_customer_id ON public.customer_tags(customer_id);
CREATE INDEX idx_customer_tags_tag_id ON public.customer_tags(tag_id);

-- Comments
COMMENT ON TABLE public.tags IS 'Tags for categorizing customers';
COMMENT ON TABLE public.customer_tags IS 'Many-to-many relationship between customers and tags';
COMMENT ON COLUMN public.tags.color IS 'Hex color code for tag display';

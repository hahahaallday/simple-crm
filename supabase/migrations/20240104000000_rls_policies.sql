-- Enable Row Level Security on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_tags ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- USERS TABLE POLICIES
-- ============================================================================

-- Users can read their own profile
CREATE POLICY "Users can view own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- Admins can view all users
CREATE POLICY "Admins can view all users"
    ON public.users FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can insert users
CREATE POLICY "Admins can insert users"
    ON public.users FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can update all users
CREATE POLICY "Admins can update all users"
    ON public.users FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can delete users
CREATE POLICY "Admins can delete users"
    ON public.users FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================================================
-- CUSTOMERS TABLE POLICIES
-- ============================================================================

-- All authenticated users can view customers (based on role)
CREATE POLICY "Authenticated users can view customers"
    ON public.customers FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager', 'agent', 'readonly')
        )
    );

-- Admins, managers, and agents can create customers
CREATE POLICY "Admins, managers, and agents can create customers"
    ON public.customers FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager', 'agent')
        )
    );

-- Admins, managers, and agents can update customers
CREATE POLICY "Admins, managers, and agents can update customers"
    ON public.customers FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager', 'agent')
        )
    );

-- Only admins can delete customers
CREATE POLICY "Admins can delete customers"
    ON public.customers FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- ============================================================================
-- TAGS TABLE POLICIES
-- ============================================================================

-- All authenticated users can view tags
CREATE POLICY "Authenticated users can view tags"
    ON public.tags FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
        )
    );

-- Admins and managers can create tags
CREATE POLICY "Admins and managers can create tags"
    ON public.tags FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager')
        )
    );

-- Admins and managers can update tags
CREATE POLICY "Admins and managers can update tags"
    ON public.tags FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager')
        )
    );

-- Admins can delete tags
CREATE POLICY "Admins can delete tags"
    ON public.tags FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- ============================================================================
-- CUSTOMER_TAGS TABLE POLICIES
-- ============================================================================

-- All authenticated users can view customer tags
CREATE POLICY "Authenticated users can view customer tags"
    ON public.customer_tags FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
        )
    );

-- Admins, managers, and agents can create customer tags
CREATE POLICY "Admins, managers, and agents can create customer tags"
    ON public.customer_tags FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager', 'agent')
        )
    );

-- Admins, managers, and agents can delete customer tags
CREATE POLICY "Admins, managers, and agents can delete customer tags"
    ON public.customer_tags FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager', 'agent')
        )
    );

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get current user's role
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT role FROM public.users
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comments
COMMENT ON FUNCTION public.is_admin() IS 'Check if current user has admin role';
COMMENT ON FUNCTION public.get_user_role() IS 'Get the role of the current authenticated user';

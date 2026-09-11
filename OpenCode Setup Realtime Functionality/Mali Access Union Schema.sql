-- ========================================================================
-- MALI ACCESS UNION-GROUP SCHEMA
-- Modern Microfinance & SACCO Management System
-- ========================================================================

-- ============================================================
-- 1. CORE GROUP TABLES
-- ============================================================

-- Groups (SACCOS/Chamas/Investment Groups)
CREATE TABLE union_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_code VARCHAR(50) UNIQUE NOT NULL,
    group_name VARCHAR(255) NOT NULL,
    group_type VARCHAR(50) NOT NULL CHECK (group_type IN ('sacco', 'chama', 'rosca', 'investment', 'emergency', 'hustler', 'cooperative')),
    description TEXT,
    registration_number VARCHAR(100),
    kra_pin VARCHAR(50),
    organization_id UUID REFERENCES organizations(id),
    
    -- Group Financials
    share_capital DECIMAL(15,2) DEFAULT 0,
    savings_pool DECIMAL(15,2) DEFAULT 0,
    loan_pool DECIMAL(15,2) DEFAULT 0,
    emergency_fund DECIMAL(15,2) DEFAULT 0,
    investment_portfolio DECIMAL(15,2) DEFAULT 0,
    
    -- Contribution Settings
    contribution_amount DECIMAL(15,2) NOT NULL,
    contribution_frequency VARCHAR(20) DEFAULT 'monthly' CHECK (contribution_frequency IN ('weekly', 'biweekly', 'monthly', 'quarterly')),
    contribution_day INTEGER DEFAULT 1,
    minimum_balance DECIMAL(15,2) DEFAULT 0,
    
    -- Loan Settings
    max_loan_multiplier DECIMAL(5,2) DEFAULT 3.00,
    interest_rate_default DECIMAL(5,2) DEFAULT 5.00,
    loan_processing_fee DECIMAL(5,2) DEFAULT 1.00,
    max_loan_term_months INTEGER DEFAULT 12,
    
    -- Members
    max_members INTEGER DEFAULT 50,
    current_members INTEGER DEFAULT 0,
    active_members INTEGER DEFAULT 0,
    
    -- Group Banks
    bank_account_id UUID REFERENCES bank_accounts(id),
    settlement_account_id UUID REFERENCES bank_accounts(id),
    
    -- Status & Tracking
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'dissolved', 'suspended', 'pending_approval')),
    risk_rating VARCHAR(20) DEFAULT 'low' CHECK (risk_rating IN ('low', 'medium', 'high', 'critical')),
    credit_score INTEGER DEFAULT 0,
    created_by UUID REFERENCES profiles(id),
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    CONSTRAINT valid_group_code CHECK (group_code ~ '^[A-Z0-9-]+$')
);

-- Group Members
CREATE TABLE union_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    user_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Member Role
    role VARCHAR(50) DEFAULT 'member' CHECK (role IN ('chairperson', 'vice_chair', 'secretary', 'treasurer', 'member', 'loan_officer')),
    
    -- Member ID
    member_number VARCHAR(50) UNIQUE,
    national_id VARCHAR(50),
    
    -- Financial Position
    share_account DECIMAL(15,2) DEFAULT 0,
    savings_balance DECIMAL(15,2) DEFAULT 0,
    loan_balance DECIMAL(15,2) DEFAULT 0,
    total_contributed DECIMAL(15,2) DEFAULT 0,
    total_borrowed DECIMAL(15,2) DEFAULT 0,
    total_interest_paid DECIMAL(15,2) DEFAULT 0,
    total_dividends_earned DECIMAL(15,2) DEFAULT 0,
    
    -- Credit Score
    credit_score INTEGER DEFAULT 0,
    credit_rating VARCHAR(20) DEFAULT 'fair' CHECK (credit_rating IN ('excellent', 'good', 'fair', 'poor', 'critical')),
    credit_limit DECIMAL(15,2) DEFAULT 0,
    
    -- Performance Metrics
    contribution_streak INTEGER DEFAULT 0,
    repayment_rate DECIMAL(5,2) DEFAULT 100.00,
    default_risk DECIMAL(5,2) DEFAULT 0,
    trust_score INTEGER DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'expelled', 'pending')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    left_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    CONSTRAINT unique_member_number UNIQUE (group_id, member_number)
);

-- ============================================================
-- 2. FINANCIAL TRANSACTIONS
-- ============================================================

-- Member Contributions
CREATE TABLE union_contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    member_id UUID NOT NULL REFERENCES union_members(id),
    
    -- Contribution Details
    contribution_type VARCHAR(50) NOT NULL CHECK (contribution_type IN ('regular', 'special', 'share_purchase', 'penalty', 'voluntary')),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'KES',
    
    -- Contribution Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    payment_method VARCHAR(50) CHECK (payment_method IN ('mpesa', 'airtel', 'bank', 'cash', 'card', 'settlement')),
    
    -- Transaction Details
    transaction_reference VARCHAR(100),
    external_reference VARCHAR(100),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'failed', 'refunded', 'reversed')),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    confirmed_by UUID REFERENCES profiles(id),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Loans
CREATE TABLE union_loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    member_id UUID NOT NULL REFERENCES union_members(id),
    
    -- Loan Details
    loan_reference VARCHAR(50) UNIQUE NOT NULL,
    loan_type VARCHAR(50) CHECK (loan_type IN ('individual', 'group', 'emergency', 'education', 'business', 'mortgage', 'asset_finance')),
    amount_approved DECIMAL(15,2) NOT NULL,
    amount_disbursed DECIMAL(15,2),
    interest_rate DECIMAL(5,2) NOT NULL,
    processing_fee DECIMAL(5,2) DEFAULT 0,
    insurance_fee DECIMAL(5,2) DEFAULT 0,
    
    -- Loan Terms
    term_months INTEGER NOT NULL,
    repayment_frequency VARCHAR(20) DEFAULT 'monthly' CHECK (repayment_frequency IN ('weekly', 'biweekly', 'monthly')),
    monthly_installment DECIMAL(15,2) NOT NULL,
    total_repayable DECIMAL(15,2) NOT NULL,
    total_interest DECIMAL(15,2) NOT NULL,
    
    -- Current Status
    amount_repaid DECIMAL(15,2) DEFAULT 0,
    balance_outstanding DECIMAL(15,2) NOT NULL,
    principal_paid DECIMAL(15,2) DEFAULT 0,
    interest_paid DECIMAL(15,2) DEFAULT 0,
    penalty_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Dates
    application_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    approval_date TIMESTAMP WITH TIME ZONE,
    disbursement_date TIMESTAMP WITH TIME ZONE,
    first_repayment_date DATE,
    next_due_date DATE,
    maturity_date DATE,
    completed_date TIMESTAMP WITH TIME ZONE,
    
    -- Loan Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'disbursed', 'active', 'overdue', 'defaulted', 'completed', 'rejected', 'cancelled')),
    overdue_days INTEGER DEFAULT 0,
    
    -- Guarantors
    guarantor_id UUID REFERENCES union_members(id),
    collateral_description TEXT,
    collateral_value DECIMAL(15,2),
    
    -- Credit Assessment
    credit_decision JSONB DEFAULT '{}',
    risk_assessment JSONB DEFAULT '{}',
    
    -- Approval Workflow
    approved_by UUID REFERENCES profiles(id),
    processed_by UUID REFERENCES profiles(id),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    CONSTRAINT valid_loan_reference CHECK (loan_reference ~ '^[A-Z0-9-]+$')
);

-- Group Loans (Joint Liability)
CREATE TABLE union_group_loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    loan_id UUID NOT NULL REFERENCES union_loans(id),
    
    -- Group Loan Details
    total_amount DECIMAL(15,2) NOT NULL,
    number_of_members INTEGER NOT NULL,
    liability_distribution JSONB DEFAULT '{}', -- Member share distribution
    
    -- Payment Allocation
    allocation_method VARCHAR(20) DEFAULT 'equal' CHECK (allocation_method IN ('equal', 'proportional', 'custom')),
    joint_liability BOOLEAN DEFAULT true,
    
    -- Tracking
    collective_balance DECIMAL(15,2) NOT NULL,
    defaulting_members INTEGER DEFAULT 0,
    guarantor_group_id UUID REFERENCES union_groups(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Loan Repayments
CREATE TABLE union_loan_repayments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loan_id UUID NOT NULL REFERENCES union_loans(id),
    member_id UUID REFERENCES union_members(id),
    group_loan_id UUID REFERENCES union_group_loans(id),
    
    -- Payment Details
    amount DECIMAL(15,2) NOT NULL,
    principal_portion DECIMAL(15,2) NOT NULL,
    interest_portion DECIMAL(15,2) NOT NULL,
    penalty_portion DECIMAL(15,2) DEFAULT 0,
    fee_portion DECIMAL(15,2) DEFAULT 0,
    
    -- Payment Method
    payment_method VARCHAR(50) CHECK (payment_method IN ('mpesa', 'airtel', 'bank', 'cash', 'deduction', 'settlement')),
    transaction_reference VARCHAR(100),
    external_reference VARCHAR(100),
    
    -- Dates
    payment_date DATE NOT NULL,
    due_date DATE NOT NULL,
    paid_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'failed', 'reversed', 'partial')),
    confirmed_by UUID REFERENCES profiles(id),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 3. CREDIT SCORE & RISK MANAGEMENT
-- ============================================================

-- Credit Scoring Engine
CREATE TABLE credit_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID NOT NULL REFERENCES union_members(id),
    group_id UUID REFERENCES union_groups(id),
    
    -- Credit Score Components
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 1000),
    rating VARCHAR(20) CHECK (rating IN ('excellent', 'good', 'fair', 'poor', 'critical')),
    
    -- Score Breakdown
    payment_history_score INTEGER DEFAULT 0, -- 35%
    credit_utilization_score INTEGER DEFAULT 0, -- 30%
    history_length_score INTEGER DEFAULT 0, -- 15%
    new_credit_score INTEGER DEFAULT 0, -- 10%
    credit_mix_score INTEGER DEFAULT 0, -- 10%
    
    -- Raw Metrics
    total_loans INTEGER DEFAULT 0,
    active_loans INTEGER DEFAULT 0,
    closed_loans INTEGER DEFAULT 0,
    defaulted_loans INTEGER DEFAULT 0,
    total_borrowed DECIMAL(15,2) DEFAULT 0,
    total_repaid DECIMAL(15,2) DEFAULT 0,
    repayment_rate DECIMAL(5,2) DEFAULT 100,
    missed_payments INTEGER DEFAULT 0,
    late_payments INTEGER DEFAULT 0,
    average_payment_delay_days INTEGER DEFAULT 0,
    
    -- Risk Indicators
    risk_category VARCHAR(20) DEFAULT 'low' CHECK (risk_category IN ('very_low', 'low', 'medium', 'high', 'very_high')),
    default_probability DECIMAL(5,2) DEFAULT 0,
    credit_limit DECIMAL(15,2) DEFAULT 0,
    max_credit_limit DECIMAL(15,2) DEFAULT 0,
    
    -- Calculation Details
    calculation_model VARCHAR(50),
    calculation_version VARCHAR(20),
    factors_used JSONB DEFAULT '{}',
    
    -- Validity
    validity_start DATE NOT NULL DEFAULT CURRENT_DATE,
    validity_end DATE,
    is_active BOOLEAN DEFAULT true,
    
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    calculated_by UUID REFERENCES profiles(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    CONSTRAINT unique_member_score UNIQUE (member_id, validity_start)
);

-- Credit Score History
CREATE TABLE credit_score_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID NOT NULL REFERENCES union_members(id),
    group_id UUID REFERENCES union_groups(id),
    
    score INTEGER NOT NULL,
    rating VARCHAR(20),
    change_reason TEXT,
    event_type VARCHAR(50) CHECK (event_type IN ('manual_update', 'loan_disbursement', 'loan_repayment', 'default', 'missed_payment', 'periodic_update')),
    
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    recorded_by UUID REFERENCES profiles(id),
    
    metadata JSONB DEFAULT '{}'
);

-- Risk Assessment
CREATE TABLE risk_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID NOT NULL REFERENCES union_members(id),
    group_id UUID REFERENCES union_groups(id),
    loan_id UUID REFERENCES union_loans(id),
    
    -- Risk Factors
    risk_score INTEGER NOT NULL,
    risk_level VARCHAR(20) CHECK (risk_level IN ('very_low', 'low', 'medium', 'high', 'very_high')),
    probability_default DECIMAL(5,2),
    expected_loss DECIMAL(15,2),
    
    -- Assessment Factors
    factors JSONB DEFAULT '{}',
    
    -- Recommended Actions
    recommendations JSONB DEFAULT '[]',
    maximum_loan_amount DECIMAL(15,2),
    required_collateral BOOLEAN DEFAULT false,
    collateral_required DECIMAL(15,2),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    
    assessed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    assessed_by UUID REFERENCES profiles(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 4. GROUP BANKING & ACCOUNTS
-- ============================================================

-- Group Banks (Mobile/Physical Banks per Group)
CREATE TABLE group_banks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Bank Details
    bank_name VARCHAR(100) NOT NULL,
    bank_code VARCHAR(20),
    branch_name VARCHAR(100),
    branch_code VARCHAR(20),
    
    -- Account Details
    account_name VARCHAR(255) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    account_type VARCHAR(50) CHECK (account_type IN ('current', 'savings', 'settlement', 'collection', 'escrow')),
    currency VARCHAR(3) DEFAULT 'KES',
    
    -- Mobile Money Details
    mobile_money_provider VARCHAR(50),
    mobile_money_number VARCHAR(50),
    mobile_money_account_name VARCHAR(255),
    
    -- Banking Services
    services JSONB DEFAULT '[]',
    fee_structure JSONB DEFAULT '{}',
    
    -- Account Status
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'closed')),
    balance DECIMAL(15,2) DEFAULT 0,
    last_synced_at TIMESTAMP WITH TIME ZONE,
    
    -- Verification
    verified BOOLEAN DEFAULT false,
    verification_document_url TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    CONSTRAINT unique_group_account UNIQUE (group_id, account_number)
);

-- Group Bank Transactions
CREATE TABLE group_bank_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_bank_id UUID NOT NULL REFERENCES group_banks(id),
    
    -- Transaction Details
    transaction_type VARCHAR(50) CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer', 'settlement', 'loan_disbursement', 'loan_repayment', 'contribution')),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'KES',
    reference VARCHAR(100) UNIQUE NOT NULL,
    
    -- Source & Destination
    source_account VARCHAR(50),
    destination_account VARCHAR(50),
    source_description TEXT,
    destination_description TEXT,
    
    -- Related Transactions
    related_contribution_id UUID REFERENCES union_contributions(id),
    related_loan_id UUID REFERENCES union_loans(id),
    related_member_id UUID REFERENCES union_members(id),
    
    -- Payment Details
    payment_method VARCHAR(50) CHECK (payment_method IN ('mpesa', 'bank_transfer', 'cheque', 'cash', 'mobile_money', 'card')),
    provider_reference VARCHAR(100),
    transaction_receipt TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'failed', 'reversed', 'cancelled')),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    confirmed_by UUID REFERENCES profiles(id),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 5. SHARES & DIVIDENDS
-- ============================================================

-- Share Trading
CREATE TABLE union_share_trading (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Share Details
    share_type VARCHAR(50) CHECK (share_type IN ('ordinary', 'preference', 'founder', 'institutional')),
    share_price DECIMAL(15,2) NOT NULL,
    minimum_shares INTEGER DEFAULT 1,
    maximum_shares INTEGER,
    
    -- Trading
    buyer_member_id UUID REFERENCES union_members(id),
    seller_member_id UUID REFERENCES union_members(id),
    number_of_shares INTEGER NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    transaction_fee DECIMAL(15,2) DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'completed', 'cancelled', 'rejected')),
    approved_by UUID REFERENCES profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Dividends
CREATE TABLE union_dividends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    member_id UUID NOT NULL REFERENCES union_members(id),
    
    -- Dividend Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Dividend Details
    dividend_type VARCHAR(50) CHECK (dividend_type IN ('cash', 'bonus_shares', 'reinvestment')),
    amount DECIMAL(15,2) NOT NULL,
    share_count INTEGER NOT NULL,
    rate_per_share DECIMAL(15,4) NOT NULL,
    total_shares_held INTEGER NOT NULL,
    
    -- Tax & Fees
    tax_amount DECIMAL(15,2) DEFAULT 0,
    fees_amount DECIMAL(15,2) DEFAULT 0,
    net_amount DECIMAL(15,2) NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'paid', 'reinvested', 'cancelled')),
    approved_by UUID REFERENCES profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE,
    paid_by UUID REFERENCES profiles(id),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 6. SAVINGS & INVESTMENTS
-- ============================================================

-- Savings Accounts
CREATE TABLE union_savings_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID NOT NULL REFERENCES union_members(id),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Account Details
    account_number VARCHAR(50) UNIQUE NOT NULL,
    account_type VARCHAR(50) CHECK (account_type IN ('regular', 'fixed', 'emergency', 'education', 'retirement', 'investment')),
    
    -- Balance
    balance DECIMAL(15,2) DEFAULT 0,
    available_balance DECIMAL(15,2) DEFAULT 0,
    locked_balance DECIMAL(15,2) DEFAULT 0,
    minimum_balance DECIMAL(15,2) DEFAULT 0,
    target_balance DECIMAL(15,2),
    
    -- Interest
    interest_rate DECIMAL(5,2) DEFAULT 2.00,
    interest_accrued DECIMAL(15,2) DEFAULT 0,
    last_interest_date DATE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'frozen', 'closed')),
    maturity_date DATE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Savings Transactions
CREATE TABLE union_savings_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    savings_account_id UUID NOT NULL REFERENCES union_savings_accounts(id),
    
    -- Transaction Details
    transaction_type VARCHAR(50) CHECK (transaction_type IN ('deposit', 'withdrawal', 'interest', 'transfer', 'penalty', 'adjustment')),
    amount DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2) NOT NULL,
    
    -- Reference
    reference VARCHAR(100) UNIQUE NOT NULL,
    related_contribution_id UUID REFERENCES union_contributions(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 7. PENALTIES & FEES
-- ============================================================

-- Penalty Rules
CREATE TABLE union_penalty_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Penalty Details
    penalty_type VARCHAR(50) CHECK (penalty_type IN ('late_payment', 'missed_contribution', 'loan_default', 'overdraft', 'early_withdrawal')),
    description TEXT,
    
    -- Penalty Calculation
    calculation_method VARCHAR(20) CHECK (calculation_method IN ('fixed', 'percentage', 'daily_interest')),
    amount DECIMAL(15,2),
    percentage DECIMAL(5,2),
    daily_rate DECIMAL(5,4),
    max_amount DECIMAL(15,2),
    grace_period_days INTEGER DEFAULT 0,
    
    -- Application
    applies_to JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Penalty Assessments
CREATE TABLE union_penalties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    member_id UUID NOT NULL REFERENCES union_members(id),
    penalty_rule_id UUID REFERENCES union_penalty_rules(id),
    
    -- Details
    amount DECIMAL(15,2) NOT NULL,
    reason TEXT,
    
    -- Related
    related_loan_id UUID REFERENCES union_loans(id),
    related_contribution_id UUID REFERENCES union_contributions(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'waived', 'cancelled')),
    paid_at TIMESTAMP WITH TIME ZONE,
    
    assessed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    assessed_by UUID REFERENCES profiles(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 8. MEETINGS & GOVERNANCE
-- ============================================================

-- Group Meetings
CREATE TABLE union_meetings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Meeting Details
    meeting_title VARCHAR(255) NOT NULL,
    meeting_type VARCHAR(50) CHECK (meeting_type IN ('annual', 'quarterly', 'monthly', 'special', 'emergency', 'board')),
    meeting_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT,
    venue VARCHAR(255),
    
    -- Agenda
    agenda TEXT,
    agenda_items JSONB DEFAULT '[]',
    duration_hours INTEGER DEFAULT 2,
    
    -- Attendance
    attendance_count INTEGER DEFAULT 0,
    attendance_list JSONB DEFAULT '[]',
    quorum_met BOOLEAN DEFAULT false,
    
    -- Minutes
    minutes TEXT,
    decisions JSONB DEFAULT '[]',
    resolutions JSONB DEFAULT '[]',
    
    -- Status
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'postponed')),
    
    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Meeting Minutes & Resolutions
CREATE TABLE union_resolutions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    meeting_id UUID REFERENCES union_meetings(id),
    
    -- Resolution Details
    resolution_number VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Voting
    votes_for INTEGER DEFAULT 0,
    votes_against INTEGER DEFAULT 0,
    votes_abstain INTEGER DEFAULT 0,
    voting_method VARCHAR(50) CHECK (voting_method IN ('simple_majority', 'two_thirds', 'unanimous', 'show_of_hands', 'secret_ballot')),
    passed BOOLEAN DEFAULT false,
    
    -- Implementation
    implementation_notes TEXT,
    assigned_to UUID REFERENCES union_members(id),
    due_date DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'proposed' CHECK (status IN ('proposed', 'approved', 'rejected', 'implemented', 'completed', 'cancelled')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 9. ACCOUNTING & RECONCILIATION
-- ============================================================

-- Chart of Accounts
CREATE TABLE union_chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Account Details
    account_code VARCHAR(20) NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    account_type VARCHAR(50) CHECK (account_type IN ('asset', 'liability', 'equity', 'income', 'expense')),
    parent_account_id UUID REFERENCES union_chart_of_accounts(id),
    
    -- Classification
    category VARCHAR(50),
    sub_category VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    CONSTRAINT unique_account_code UNIQUE (group_id, account_code)
);

-- Journal Entries
CREATE TABLE union_journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Entry Details
    entry_number VARCHAR(50) UNIQUE NOT NULL,
    entry_date DATE NOT NULL,
    description TEXT,
    
    -- Amount
    total_debit DECIMAL(15,2) NOT NULL,
    total_credit DECIMAL(15,2) NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50),
    reference_id UUID,
    reference_number VARCHAR(100),
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'posted', 'approved', 'reversed', 'cancelled')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    posted_by UUID REFERENCES profiles(id),
    approved_by UUID REFERENCES profiles(id)
);

-- Journal Entry Items
CREATE TABLE union_journal_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES union_journal_entries(id),
    account_id UUID NOT NULL REFERENCES union_chart_of_accounts(id),
    
    -- Debit/Credit
    debit DECIMAL(15,2) DEFAULT 0,
    credit DECIMAL(15,2) DEFAULT 0,
    
    -- Details
    description TEXT,
    reference_number VARCHAR(100),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 10. REPORTS & ANALYTICS
-- ============================================================

-- Report Definitions
CREATE TABLE union_report_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES union_groups(id),
    
    -- Report Details
    report_name VARCHAR(255) NOT NULL,
    report_category VARCHAR(50) CHECK (report_category IN ('financial', 'member', 'loan', 'savings', 'compliance', 'performance')),
    description TEXT,
    
    -- Report Configuration
    query JSONB DEFAULT '{}',
    parameters JSONB DEFAULT '{}',
    schedule_config JSONB DEFAULT '{}',
    
    -- Output
    output_format VARCHAR(20) DEFAULT 'pdf' CHECK (output_format IN ('pdf', 'excel', 'csv', 'json', 'html')),
    output_template TEXT,
    
    -- Permissions
    roles_access JSONB DEFAULT '[]',
    
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Generated Reports
CREATE TABLE union_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_definition_id UUID NOT NULL REFERENCES union_report_definitions(id),
    group_id UUID REFERENCES union_groups(id),
    
    -- Report Execution
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    executed_by UUID REFERENCES profiles(id),
    parameters_used JSONB DEFAULT '{}',
    
    -- Results
    result_data JSONB DEFAULT '{}',
    summary JSONB DEFAULT '{}',
    file_url TEXT,
    file_size INTEGER,
    
    -- Status
    status VARCHAR(20) DEFAULT 'generated' CHECK (status IN ('generated', 'processing', 'completed', 'failed')),
    error_message TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 11. AUDIT & COMPLIANCE
-- ============================================================

-- Audit Trail
CREATE TABLE union_audit_trail (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES union_groups(id),
    
    -- Audit Details
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID NOT NULL,
    
    -- Changes
    old_values JSONB DEFAULT '{}',
    new_values JSONB DEFAULT '{}',
    
    -- Actor
    actor_id UUID REFERENCES profiles(id),
    actor_ip INET,
    actor_user_agent TEXT,
    
    -- Context
    context JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Compliance Requirements
CREATE TABLE union_compliance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Requirement Details
    requirement_type VARCHAR(50) CHECK (requirement_type IN ('regulatory', 'legal', 'internal', 'audit', 'reporting')),
    requirement_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Compliance Tracking
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'compliant', 'non_compliant', 'exempt')),
    due_date DATE,
    compliance_date DATE,
    
    -- Documentation
    documentation_url TEXT,
    notes TEXT,
    
    -- Verification
    verified_by UUID REFERENCES profiles(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 12. NOTIFICATIONS & COMMUNICATIONS
-- ============================================================

-- Group Notifications
CREATE TABLE union_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES union_groups(id),
    member_id UUID REFERENCES union_members(id),
    
    -- Notification Details
    notification_type VARCHAR(50) CHECK (notification_type IN ('payment_due', 'loan_approved', 'contribution_reminder', 'meeting_reminder', 'dividend_alert', 'general_announcement')),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    
    -- Delivery
    channel VARCHAR(50) CHECK (channel IN ('sms', 'email', 'push', 'in_app', 'whatsapp', 'telegram')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    
    -- Status
    sent BOOLEAN DEFAULT false,
    read BOOLEAN DEFAULT false,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Scheduling
    scheduled_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 13. MEMBERSHIP & ONBOARDING
-- ============================================================

-- Member Applications
CREATE TABLE union_member_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES union_groups(id),
    
    -- Applicant Details
    applicant_name VARCHAR(255) NOT NULL,
    applicant_email VARCHAR(255),
    applicant_phone VARCHAR(50),
    applicant_national_id VARCHAR(50),
    
    -- Application
    application_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    application_type VARCHAR(50) CHECK (application_type IN ('new_member', 'share_purchase', 'loan_application', 'other')),
    details JSONB DEFAULT '{}',
    
    -- Verification
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'approved', 'rejected', 'in_review')),
    verification_notes TEXT,
    verified_by UUID REFERENCES profiles(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Result
    approved BOOLEAN DEFAULT false,
    approved_by UUID REFERENCES profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    
    -- References
    reference1_name VARCHAR(255),
    reference1_phone VARCHAR(50),
    reference2_name VARCHAR(255),
    reference2_phone VARCHAR(50),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 14. INTEGRATIONS & WEBHOOKS
-- ============================================================

-- Integration Configurations
CREATE TABLE union_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES union_groups(id),
    
    -- Integration Details
    integration_type VARCHAR(50) CHECK (integration_type IN ('accounting', 'sms', 'email', 'payment_gateway', 'crm', 'core_banking')),
    provider VARCHAR(100),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Configuration
    config JSONB DEFAULT '{}',
    credentials_encrypted TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    status VARCHAR(20) DEFAULT 'connected' CHECK (status IN ('connected', 'disconnected', 'error', 'pending')),
    last_sync_at TIMESTAMP WITH TIME ZONE,
    last_sync_status VARCHAR(50),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Webhook Events
CREATE TABLE union_webhook_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES union_groups(id),
    
    -- Event Details
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    
    -- Webhook Target
    webhook_url TEXT NOT NULL,
    webhook_headers JSONB DEFAULT '{}',
    
    -- Delivery
    delivery_status VARCHAR(20) DEFAULT 'pending' CHECK (delivery_status IN ('pending', 'sent', 'failed', 'completed')),
    delivery_attempts INTEGER DEFAULT 0,
    last_delivery_at TIMESTAMP WITH TIME ZONE,
    response_status INTEGER,
    response_body TEXT,
    
    -- Retry
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    next_retry_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 15. SYSTEM & MAINTENANCE
-- ============================================================

-- System Configurations
CREATE TABLE union_system_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES union_groups(id),
    
    config_key VARCHAR(255) NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    category VARCHAR(50),
    
    -- Access Control
    is_public BOOLEAN DEFAULT false,
    roles_editable JSONB DEFAULT '[]',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    CONSTRAINT unique_config_key UNIQUE (group_id, config_key)
);

-- System Logs
CREATE TABLE union_system_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES union_groups(id),
    
    -- Log Details
    log_level VARCHAR(20) CHECK (log_level IN ('debug', 'info', 'warning', 'error', 'critical')),
    source VARCHAR(100),
    message TEXT NOT NULL,
    
    -- Context
    context JSONB DEFAULT '{}',
    user_id UUID REFERENCES profiles(id),
    
    -- Environment
    environment VARCHAR(50),
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- 16. INDEXES & PERFORMANCE OPTIMIZATION
-- ============================================================

-- Indexes for union_members
CREATE INDEX idx_union_members_group ON union_members(group_id);
CREATE INDEX idx_union_members_user ON union_members(user_id);
CREATE INDEX idx_union_members_status ON union_members(status);
CREATE INDEX idx_union_members_credit_score ON union_members(credit_score);

-- Indexes for union_loans
CREATE INDEX idx_union_loans_group ON union_loans(group_id);
CREATE INDEX idx_union_loans_member ON union_loans(member_id);
CREATE INDEX idx_union_loans_status ON union_loans(status);
CREATE INDEX idx_union_loans_due_date ON union_loans(next_due_date);

-- Indexes for union_contributions
CREATE INDEX idx_union_contributions_group ON union_contributions(group_id);
CREATE INDEX idx_union_contributions_member ON union_contributions(member_id);
CREATE INDEX idx_union_contributions_period ON union_contributions(period_start, period_end);

-- Indexes for loan_repayments
CREATE INDEX idx_loan_repayments_loan ON union_loan_repayments(loan_id);
CREATE INDEX idx_loan_repayments_member ON union_loan_repayments(member_id);
CREATE INDEX idx_loan_repayments_date ON union_loan_repayments(payment_date);

-- Indexes for group_bank_transactions
CREATE INDEX idx_group_bank_transactions_bank ON group_bank_transactions(group_bank_id);
CREATE INDEX idx_group_bank_transactions_reference ON group_bank_transactions(reference);
CREATE INDEX idx_group_bank_transactions_date ON group_bank_transactions(created_at);

-- Indexes for credit_scores
CREATE INDEX idx_credit_scores_member ON credit_scores(member_id);
CREATE INDEX idx_credit_scores_rating ON credit_scores(rating);
CREATE INDEX idx_credit_scores_score ON credit_scores(score);

-- Indexes for union_audit_trail
CREATE INDEX idx_union_audit_trail_resource ON union_audit_trail(resource_type, resource_id);
CREATE INDEX idx_union_audit_trail_actor ON union_audit_trail(actor_id);
CREATE INDEX idx_union_audit_trail_created ON union_audit_trail(created_at);

-- ============================================================
-- 17. RLS POLICIES (SQL)
-- ============================================================

-- -- Enable Row Level Security
-- ALTER TABLE union_groups ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE union_members ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE union_loans ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE union_contributions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE union_loan_repayments ENABLE ROW LEVEL SECURITY;

-- -- Policies for union_groups
-- CREATE POLICY "Members can view their groups" ON union_groups
--     FOR SELECT USING (
--         id IN (SELECT group_id FROM union_members WHERE user_id = auth.uid())
--         OR created_by = auth.uid()
--     );

-- CREATE POLICY "Admins can manage groups" ON union_groups
--     FOR ALL USING (
--         auth.uid() IN (SELECT user_id FROM profiles WHERE role IN ('admin', 'super_admin'))
--     );

-- -- Policies for union_members
-- CREATE POLICY "Members can view members in their groups" ON union_members
--     FOR SELECT USING (
--         group_id IN (SELECT group_id FROM union_members WHERE user_id = auth.uid())
--     );

-- CREATE POLICY "Members can update their own profile" ON union_members
--     FOR UPDATE USING (user_id = auth.uid());

-- -- Policies for union_loans
-- CREATE POLICY "Members can view their loans" ON union_loans
--     FOR SELECT USING (
--         member_id IN (SELECT id FROM union_members WHERE user_id = auth.uid())
--     );

-- CREATE POLICY "Loan officers can manage loans" ON union_loans
--     FOR ALL USING (
--         auth.uid() IN (
--             SELECT user_id FROM union_members 
--             WHERE role IN ('loan_officer', 'chairperson', 'treasurer')
--             AND group_id = union_loans.group_id
--         )
--     );
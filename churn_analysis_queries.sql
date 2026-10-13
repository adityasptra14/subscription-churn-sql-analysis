-- =====================================================================
-- PROYEK: ANALISIS CUSTOMER CHURN & RETENSI PELANGGAN
-- Dialek: SQL (SQLite / Standard ANSI SQL)
-- =====================================================================

-- 1. Evaluasi Churn Rate dan Revenue Lost Berdasarkan Jenis Kontrak
SELECT 
    contract_type AS Jenis_Kontrak,
    COUNT(customer_id) AS Total_Pelanggan,
    SUM(churn_status) AS Pelanggan_Churn,
    ROUND(AVG(churn_status) * 100, 2) AS Churn_Rate_Pct,
    SUM(CASE WHEN churn_status = 1 THEN monthly_charge ELSE 0 END) AS Revenue_Lost_IDR
FROM subscriptions
GROUP BY contract_type
ORDER BY Churn_Rate_Pct DESC;

-- 2. Cohort Analysis Masa Aktif Pelanggan Menggunakan CTE (WITH Clause)
WITH Tenure_Cohort AS (
    SELECT 
        customer_id,
        churn_status,
        monthly_charge,
        CASE 
            WHEN tenure_months <= 3 THEN '1. Bulan 1-3 (Onboarding)'
            WHEN tenure_months BETWEEN 4 AND 6 THEN '2. Bulan 4-6 (Adaptasi)'
            WHEN tenure_months BETWEEN 7 AND 12 THEN '3. Bulan 7-12 (Menengah)'
            ELSE '4. > 12 Bulan (Loyal)'
        END AS Kelompok_Masa_Aktif
    FROM subscriptions
)
SELECT 
    Kelompok_Masa_Aktif,
    COUNT(customer_id) AS Total_Pelanggan,
    SUM(churn_status) AS Jumlah_Churn,
    ROUND(AVG(churn_status) * 100, 2) AS Churn_Rate_Pct,
    SUM(CASE WHEN churn_status = 1 THEN monthly_charge ELSE 0 END) AS Pendapatan_Hilang
FROM Tenure_Cohort
GROUP BY Kelompok_Masa_Aktif
ORDER BY Kelompok_Masa_Aktif;

-- 3. Analisis Dampak Keluhan Pelanggan & Metode Pembayaran (Multi-Table JOIN)
SELECT 
    s.payment_method AS Metode_Pembayaran,
    COUNT(s.customer_id) AS Total_Pelanggan,
    ROUND(AVG(t.ticket_count), 2) AS Rata_Rata_Komplain,
    ROUND(AVG(s.churn_status) * 100, 2) AS Churn_Rate_Pct
FROM subscriptions s
INNER JOIN support_tickets t ON s.customer_id = t.customer_id
INNER JOIN customers c ON s.customer_id = c.customer_id
GROUP BY s.payment_method
ORDER BY Churn_Rate_Pct DESC;

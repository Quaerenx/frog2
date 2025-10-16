package com.company.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.company.util.DBConnection;

public class MaintenanceRecordDAO {

    // 담당자별로 정기점검 이력을 그룹화하여 조회
    public Map<String, List<MaintenanceRecordDTO>> getMaintenanceRecordsByInspector() {
        Map<String, List<MaintenanceRecordDTO>> inspectorRecords = new LinkedHashMap<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM maintenance_records ORDER BY inspector_name, inspection_date DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            boolean hasSize = columnExists(conn, "maintenance_records", "license_size_gb");
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            boolean hasUsageSize = columnExists(conn, "maintenance_records", "license_usage_size");

            while (rs.next()) {
                MaintenanceRecordDTO record = mapRowToDto(rs, hasSize, hasUsagePct, hasUsageSize);
                String inspectorName = record.getInspectorName();
                inspectorRecords.computeIfAbsent(inspectorName, k -> new ArrayList<>()).add(record);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return inspectorRecords;
    }

    // 모든 정기점검 이력 조회
    public List<MaintenanceRecordDTO> getAllMaintenanceRecords() {
        List<MaintenanceRecordDTO> records = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM maintenance_records ORDER BY inspection_date DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            boolean hasSize = columnExists(conn, "maintenance_records", "license_size_gb");
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            boolean hasUsageSize = columnExists(conn, "maintenance_records", "license_usage_size");

            while (rs.next()) {
                MaintenanceRecordDTO record = mapRowToDto(rs, hasSize, hasUsagePct, hasUsageSize);
                records.add(record);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return records;
    }

    // 특정 담당자의 고객사 목록 조회 (활성 상태 고객사만)
    public List<String> getCustomersByInspector(String inspectorName) {
        List<String> customers = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT DISTINCT customer_name FROM vertica_customer_detail " +
                        "WHERE (main_manager = ? OR sub_manager = ?) " +
                        "ORDER BY customer_name";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, inspectorName);
            pstmt.setString(2, inspectorName);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                customers.add(rs.getString("customer_name"));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return customers;
    }

    // 새로운 정기점검 이력 추가 (존재하는 컬럼만 동적으로 포함)
    public boolean addMaintenanceRecord(MaintenanceRecordDTO record) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            boolean hasSize = columnExists(conn, "maintenance_records", "license_size_gb");
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            boolean hasUsageSize = columnExists(conn, "maintenance_records", "license_usage_size");

            // 기본 컬럼
            List<String> cols = new ArrayList<>();
            cols.add("customer_name");
            cols.add("inspector_name");
            cols.add("inspection_date");
            cols.add("vertica_version");
            cols.add("note");

            // 선택 컬럼
            if (hasSize) cols.add("license_size_gb");
            if (hasUsageSize) cols.add("license_usage_size");
            if (hasUsagePct) cols.add("license_usage_pct");

            StringBuilder sb = new StringBuilder();
            sb.append("INSERT INTO maintenance_records (");
            sb.append(String.join(", ", cols));
            sb.append(") VALUES (");
            for (int i = 0; i < cols.size(); i++) {
                if (i > 0) sb.append(", ");
                sb.append("?");
            }
            sb.append(")");

            pstmt = conn.prepareStatement(sb.toString());
            int idx = 1;
            pstmt.setString(idx++, record.getCustomerName());
            pstmt.setString(idx++, record.getInspectorName());
            pstmt.setDate(idx++, record.getInspectionDate());
            setStringOrNull(pstmt, idx++, record.getVerticaVersion());
            setStringOrNull(pstmt, idx++, record.getNote());
            if (hasSize) setStringOrNull(pstmt, idx++, record.getLicenseSizeGb());
            if (hasUsageSize) setStringOrNull(pstmt, idx++, record.getLicenseUsageSize());
            if (hasUsagePct) setStringOrNull(pstmt, idx++, record.getLicenseUsagePct());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 정기점검 이력 수정 (존재하는 컬럼만 동적으로 포함)
    public boolean updateMaintenanceRecord(MaintenanceRecordDTO record) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            boolean hasSize = columnExists(conn, "maintenance_records", "license_size_gb");
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            boolean hasUsageSize = columnExists(conn, "maintenance_records", "license_usage_size");

            StringBuilder sb = new StringBuilder();
            sb.append("UPDATE maintenance_records SET ");
            sb.append("customer_name = ?, inspector_name = ?, inspection_date = ?, vertica_version = ?, note = ?");
            if (hasSize) sb.append(", license_size_gb = ?");
            if (hasUsageSize) sb.append(", license_usage_size = ?");
            if (hasUsagePct) sb.append(", license_usage_pct = ?");
            sb.append(", updated_at = statement_timestamp() WHERE maintenance_id = ?");

            pstmt = conn.prepareStatement(sb.toString());
            int idx = 1;
            pstmt.setString(idx++, record.getCustomerName());
            pstmt.setString(idx++, record.getInspectorName());
            pstmt.setDate(idx++, record.getInspectionDate());
            setStringOrNull(pstmt, idx++, record.getVerticaVersion());
            setStringOrNull(pstmt, idx++, record.getNote());
            if (hasSize) setStringOrNull(pstmt, idx++, record.getLicenseSizeGb());
            if (hasUsageSize) setStringOrNull(pstmt, idx++, record.getLicenseUsageSize());
            if (hasUsagePct) setStringOrNull(pstmt, idx++, record.getLicenseUsagePct());
            pstmt.setLong(idx++, record.getMaintenanceId());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 정기점검 이력 삭제
    public boolean deleteMaintenanceRecord(Long maintenanceId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "DELETE FROM maintenance_records WHERE maintenance_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1, maintenanceId);

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // ID로 특정 정기점검 이력 조회
    public MaintenanceRecordDTO getMaintenanceRecordById(Long maintenanceId) {
        MaintenanceRecordDTO record = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM maintenance_records WHERE maintenance_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1, maintenanceId);
            rs = pstmt.executeQuery();

            boolean hasSize = columnExists(conn, "maintenance_records", "license_size_gb");
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            boolean hasUsageSize = columnExists(conn, "maintenance_records", "license_usage_size");

            if (rs.next()) {
                record = mapRowToDto(rs, hasSize, hasUsagePct, hasUsageSize);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return record;
    }

    // 특정 고객사의 정기점검 이력 조회
    public List<MaintenanceRecordDTO> getMaintenanceRecordsByCustomer(String customerName) {
        List<MaintenanceRecordDTO> records = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM maintenance_records WHERE customer_name = ? ORDER BY inspection_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customerName);
            rs = pstmt.executeQuery();

            boolean hasSize = columnExists(conn, "maintenance_records", "license_size_gb");
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            boolean hasUsageSize = columnExists(conn, "maintenance_records", "license_usage_size");

            while (rs.next()) {
                MaintenanceRecordDTO record = mapRowToDto(rs, hasSize, hasUsagePct, hasUsageSize);
                records.add(record);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return records;
    }

    // 고객사의 점검일/라이선스 사용률(%) 시계열 조회 (문자열 컬럼을 정수로 파싱)
    public List<Map<String, Object>> getLicenseUsageSeries(String customerName) {
        List<Map<String, Object>> points = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            if (!hasUsagePct) {
                return points; // 컬럼이 없으면 빈 결과 반환
            }

            String sql = "SELECT inspection_date, license_usage_pct AS usage_val FROM maintenance_records WHERE customer_name = ? AND license_usage_pct IS NOT NULL ORDER BY inspection_date ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customerName);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> point = new LinkedHashMap<>();
                java.sql.Date d = rs.getDate("inspection_date");
                String usageStr = rs.getString("usage_val");
                point.put("date", d != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(d) : null);
                point.put("value", tryParseInt(usageStr));
                points.add(point);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return points;
    }

    // 빈 문자열을 NULL로 처리하는 도우미 메서드
    private void setStringOrNull(PreparedStatement pstmt, int parameterIndex, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) {
            pstmt.setNull(parameterIndex, Types.VARCHAR);
        } else {
            pstmt.setString(parameterIndex, value.trim());
        }
    }

    private MaintenanceRecordDTO mapRowToDto(ResultSet rs, boolean hasSize, boolean hasUsagePct, boolean hasUsageSize) throws SQLException {
        MaintenanceRecordDTO record = new MaintenanceRecordDTO();
        record.setMaintenanceId(rs.getLong("maintenance_id"));
        record.setCustomerName(rs.getString("customer_name"));
        record.setInspectorName(rs.getString("inspector_name"));
        record.setInspectionDate(rs.getDate("inspection_date"));
        record.setVerticaVersion(rs.getString("vertica_version"));
        record.setNote(rs.getString("note"));
        record.setCreatedAt(rs.getTimestamp("created_at"));
        record.setUpdatedAt(rs.getTimestamp("updated_at"));

        if (hasSize) {
            record.setLicenseSizeGb(rs.getString("license_size_gb"));
        }
        if (hasUsageSize) {
            record.setLicenseUsageSize(rs.getString("license_usage_size"));
        }
        if (hasUsagePct) {
            record.setLicenseUsagePct(rs.getString("license_usage_pct"));
        }

        return record;
    }

    private Integer tryParseInt(String s) {
        if (s == null) return null;
        try {
            String trimmed = s.trim();
            if (trimmed.isEmpty()) return null;
            // 숫자만 남기고 파싱 시도 (예: "75%" -> 75)
            String digits = trimmed.replaceAll("[^0-9-]", "");
            if (digits.isEmpty()) return null;
            return Integer.parseInt(digits);
        } catch (Exception e) {
            return null;
        }
    }

    private boolean columnExists(Connection conn, String tableName, String columnName) {
        ResultSet rs = null;
        try {
            java.sql.DatabaseMetaData meta = conn.getMetaData();
            rs = meta.getColumns(null, null, tableName, columnName);
            if (rs.next()) return true;
            DBConnection.close(rs);
            rs = meta.getColumns(null, null, tableName.toUpperCase(), columnName.toUpperCase());
            return rs.next();
        } catch (SQLException e) {
            return false;
        } finally {
            DBConnection.close(rs);
        }
    }

    public MaintenanceRecordDTO getLatestMaintenanceRecordForCustomer(String customerName) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            boolean hasSize = columnExists(conn, "maintenance_records", "license_size_gb");
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            boolean hasUsageSize = columnExists(conn, "maintenance_records", "license_usage_size");

            String sql = "SELECT * FROM maintenance_records WHERE customer_name = ? ORDER BY inspection_date DESC LIMIT 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customerName);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return mapRowToDto(rs, hasSize, hasUsagePct, hasUsageSize);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }
        return null;
    }
}
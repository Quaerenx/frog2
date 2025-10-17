package com.company.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.company.util.DBConnection;

public class MaintenanceRecordDAO {

    // licnese_usage_pct 오탈자 컬럼이 존재하고 정식 컬럼이 없으면 스키마를 정정한다.
    private void ensureUsagePctColumnRenamed() {
        Connection conn = null;
        Statement stmt = null;
        try {
            conn = DBConnection.getConnection();
            boolean hasTypo = columnExists(conn, "maintenance_records", "licnese_usage_pct");
            boolean hasCorrect = columnExists(conn, "maintenance_records", "license_usage_pct");
            if (hasTypo && !hasCorrect) {
                stmt = conn.createStatement();
                stmt.executeUpdate("ALTER TABLE maintenance_records RENAME COLUMN licnese_usage_pct TO license_usage_pct");
            }
        } catch (Exception ignored) {
            // 무해하게 무시 (권한 없거나 이미 처리된 경우)
        } finally {
            DBConnection.close(stmt);
            DBConnection.close(conn);
        }
    }

    // 담당자별로 정기점검 이력을 그룹화하여 조회
    public Map<String, List<MaintenanceRecordDTO>> getMaintenanceRecordsByInspector() {
        ensureUsagePctColumnRenamed();
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
        ensureUsagePctColumnRenamed();
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
        ensureUsagePctColumnRenamed();
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
            if (hasUsagePct) {
                cols.add("license_usage_pct");
            }

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
        ensureUsagePctColumnRenamed();
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
        ensureUsagePctColumnRenamed();
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
        ensureUsagePctColumnRenamed();
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

    // 고객사의 점검일/라이선스 사용률(%) 시계열 조회: 날짜별로 사용률/사용량(TB)/라이선스 크기(TB)를 모두 포함해 반환
    public List<Map<String, Object>> getLicenseUsageSeries(String customerName) {
        ensureUsagePctColumnRenamed();
        List<Map<String, Object>> points = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            boolean hasUsagePct = columnExists(conn, "maintenance_records", "license_usage_pct");
            boolean hasSize = columnExists(conn, "maintenance_records", "license_size_gb");
            boolean hasUsageSize = columnExists(conn, "maintenance_records", "license_usage_size");
            if (!hasUsagePct && !hasSize && !hasUsageSize) {
                return points; // 아무 관련 컬럼도 없으면 빈 결과
            }

            String sql = "SELECT inspection_date, " +
                         (hasUsagePct ? "license_usage_pct" : "NULL AS license_usage_pct") + ", " +
                         (hasSize ? "license_size_gb" : "NULL AS license_size_gb") + ", " +
                         (hasUsageSize ? "license_usage_size" : "NULL AS license_usage_size") +
                         " FROM maintenance_records WHERE customer_name = ? " +
                         " AND (" + (hasUsagePct ? "license_usage_pct IS NOT NULL" : "1=0") +
                         " OR " + (hasSize ? "license_size_gb IS NOT NULL" : "1=0") +
                         " OR " + (hasUsageSize ? "license_usage_size IS NOT NULL" : "1=0") + ") " +
                         " ORDER BY inspection_date ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customerName);
            rs = pstmt.executeQuery();

            java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd");

            while (rs.next()) {
                java.sql.Date d = rs.getDate("inspection_date");
                if (d == null) continue;

                String pctStr = hasUsagePct ? rs.getString("license_usage_pct") : null;
                String sizeStr = hasSize ? rs.getString("license_size_gb") : null; // 실제 단위는 TB
                String usageSizeStr = hasUsageSize ? rs.getString("license_usage_size") : null; // TB 단위

                // 값 파싱
                Integer pct = tryParseInt(pctStr);
                Double sizeTb = parseToTbStrict(sizeStr);   // TB로 파싱
                Double usedTb = parseToTbStrict(usageSizeStr); // TB로 파싱

                // 사용률 미제공 시 size/usage로 계산
                if (pct == null && sizeTb != null && sizeTb > 0 && usedTb != null) {
                    int rounded = (int) Math.round((usedTb / sizeTb) * 100.0);
                    pct = rounded;
                }
                // 사용량 미제공 시 size와 pct로 계산
                if (usedTb == null && sizeTb != null && pct != null) {
                    usedTb = (sizeTb * pct) / 100.0;
                }
                // 라이선스 크기 미제공 시 used와 pct로 계산 (pct>0 보호)
                if (sizeTb == null && usedTb != null && pct != null && pct > 0) {
                    sizeTb = (usedTb * 100.0) / pct;
                }

                Map<String, Object> point = new LinkedHashMap<>();
                point.put("date", df.format(d));
                if (pct != null) point.put("value", pct); // 기존 호환 키
                else point.put("value", null);
                point.put("pct", pct);       // 명시 키
                point.put("usedTb", usedTb);  // 사용량(TB)
                point.put("sizeTb", sizeTb);  // 라이선스 크기(TB)
                points.add(point);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return points;
    }

    // TB 단위 숫자로 안전 파싱: "3.5TB" -> 3.5, "3500 GB" -> 3.41796875, 단위 없으면 TB로 간주
    private Double parseToTbStrict(String s) {
        if (s == null) return null;
        String raw = s.trim();
        if (raw.isEmpty()) return null;
        String lower = raw.toLowerCase();
        boolean hasGb = lower.contains("gb");
        boolean hasTb = lower.contains("tb");
        Double n = parseNumber(raw);
        if (n == null) return null;
        if (hasGb) return n / 1024.0;  // GB -> TB 변환
        // TB 명시 또는 단위 미표시 시 TB로 취급
        return n;
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
            record.setLicenseSizeGb(getColumnIfExists(rs, "license_size_gb"));
        }
        if (hasUsageSize) {
            record.setLicenseUsageSize(getColumnIfExists(rs, "license_usage_size"));
        }
        if (hasUsagePct) {
            String pct = getColumnIfExists(rs, "license_usage_pct");
            record.setLicenseUsagePct(pct);
        }

        return record;
    }

    private String getColumnIfExists(ResultSet rs, String col) {
        try {
            ResultSetMetaData md = rs.getMetaData();
            int count = md.getColumnCount();
            for (int i = 1; i <= count; i++) {
                String name = md.getColumnLabel(i);
                if (name == null || name.isEmpty()) name = md.getColumnName(i);
                if (name != null && name.equalsIgnoreCase(col)) {
                    return rs.getString(col);
                }
            }
        } catch (SQLException ignored) {
        }
        return null;
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

    // 숫자/단위 문자열을 안전하게 숫자로 파싱
    private Double parseNumber(String s) {
        if (s == null) return null;
        String t = s.trim();
        if (t.isEmpty()) return null;
        // 콤마 제거 후 숫자/소수/부호만 유지
        t = t.replace(",", "");
        t = t.replaceAll("[^0-9.\\-]", "");
        if (t.isEmpty() || t.equals("-") || t.equals(".")) return null;
        try {
            return Double.parseDouble(t);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // "12TB", "500 GB" 같은 값을 GB 단위 숫자로 환산
    private Double parseToGb(String s) {
        if (s == null) return null;
        String raw = s.trim();
        if (raw.isEmpty()) return null;
        String lower = raw.toLowerCase();
        boolean isTb = lower.contains("tb");
        boolean isGb = lower.contains("gb");
        Double n = parseNumber(raw);
        if (n == null) return null;
        if (isTb || (!isGb && !isTb)) {
            // TB 명시 또는 단위 미표시(기본 TB)인 경우 GB로 환산
            return n * 1024.0;
        }
        return n; // GB 명시 시 그대로 반환
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

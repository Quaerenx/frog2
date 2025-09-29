package com.company.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.company.util.DBConnection;

public class TroubleshootingDAO {

    // 모든 트러블 슈팅 목록 조회
    public List<TroubleshootingDTO> getAllTroubleshooting() {
        List<TroubleshootingDTO> troubleshootingList = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT id, title, customer_name, occurrence_date, creator, create_date " +
                        "FROM troubleshooting ORDER BY create_date DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                TroubleshootingDTO ts = new TroubleshootingDTO();
                ts.setId(rs.getInt("id"));
                ts.setTitle(rs.getString("title"));
                ts.setCustomerName(rs.getString("customer_name"));

                Timestamp occurrenceTs = rs.getTimestamp("occurrence_date");
                if (occurrenceTs != null) {
                    ts.setOccurrenceDate(new java.util.Date(occurrenceTs.getTime()));
                }

                ts.setCreator(rs.getString("creator"));

                Timestamp createTs = rs.getTimestamp("create_date");
                if (createTs != null) {
                    ts.setCreateDate(new java.util.Date(createTs.getTime()));
                }

                troubleshootingList.add(ts);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return troubleshootingList;
    }

    // 특정 트러블 슈팅 상세 조회
    public TroubleshootingDTO getTroubleshootingById(int id) {
        TroubleshootingDTO ts = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM troubleshooting WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                ts = new TroubleshootingDTO();
                ts.setId(rs.getInt("id"));
                ts.setTitle(rs.getString("title"));
                ts.setCustomerName(rs.getString("customer_name"));
                ts.setCustomerManager(rs.getString("customer_manager"));

                Timestamp occurrenceTs = rs.getTimestamp("occurrence_date");
                if (occurrenceTs != null) {
                    ts.setOccurrenceDate(new java.util.Date(occurrenceTs.getTime()));
                }

                ts.setWorkPersonnel(rs.getString("work_personnel"));
                ts.setWorkPeriod(rs.getString("work_period"));
                ts.setCreator(rs.getString("creator"));

                Timestamp createTs = rs.getTimestamp("create_date");
                if (createTs != null) {
                    ts.setCreateDate(new java.util.Date(createTs.getTime()));
                }

                ts.setSupportType(rs.getString("support_type"));
                ts.setCaseOpenYn(rs.getString("case_open_yn"));
                ts.setOverview(rs.getString("overview"));
                ts.setCauseAnalysis(rs.getString("cause_analysis"));
                ts.setErrorContent(rs.getString("error_content"));
                ts.setActionTaken(rs.getString("action_taken"));
                ts.setScriptContent(rs.getString("script_content"));
                ts.setNote(rs.getString("note"));

                Timestamp updatedTs = rs.getTimestamp("updated_date");
                if (updatedTs != null) {
                    ts.setUpdatedDate(new java.util.Date(updatedTs.getTime()));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return ts;
    }

    // 새 트러블 슈팅 추가
    public boolean addTroubleshooting(TroubleshootingDTO ts) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO troubleshooting (" +
                        "title, customer_name, customer_manager, occurrence_date, work_personnel, " +
                        "work_period, creator, support_type, case_open_yn, overview, " +
                        "cause_analysis, error_content, action_taken, script_content, note" +
                        ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, ts.getTitle());
            pstmt.setString(2, ts.getCustomerName());
            setStringOrNull(pstmt, 3, ts.getCustomerManager());

            if (ts.getOccurrenceDate() != null) {
                pstmt.setTimestamp(4, new Timestamp(ts.getOccurrenceDate().getTime()));
            } else {
                pstmt.setNull(4, Types.TIMESTAMP);
            }

            setStringOrNull(pstmt, 5, ts.getWorkPersonnel());
            setStringOrNull(pstmt, 6, ts.getWorkPeriod());
            pstmt.setString(7, ts.getCreator());
            setStringOrNull(pstmt, 8, ts.getSupportType());
            setStringOrNull(pstmt, 9, ts.getCaseOpenYn());
            setStringOrNull(pstmt, 10, ts.getOverview());
            setStringOrNull(pstmt, 11, ts.getCauseAnalysis());
            setStringOrNull(pstmt, 12, ts.getErrorContent());
            setStringOrNull(pstmt, 13, ts.getActionTaken());
            setStringOrNull(pstmt, 14, ts.getScriptContent());
            setStringOrNull(pstmt, 15, ts.getNote());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 트러블 슈팅 수정
    public boolean updateTroubleshooting(TroubleshootingDTO ts) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE troubleshooting SET " +
                        "title = ?, customer_name = ?, customer_manager = ?, occurrence_date = ?, " +
                        "work_personnel = ?, work_period = ?, support_type = ?, case_open_yn = ?, " +
                        "overview = ?, cause_analysis = ?, error_content = ?, action_taken = ?, " +
                        "script_content = ?, note = ?, updated_date = NOW() " +
                        "WHERE id = ?";

            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, ts.getTitle());
            pstmt.setString(2, ts.getCustomerName());
            setStringOrNull(pstmt, 3, ts.getCustomerManager());

            if (ts.getOccurrenceDate() != null) {
                pstmt.setTimestamp(4, new Timestamp(ts.getOccurrenceDate().getTime()));
            } else {
                pstmt.setNull(4, Types.TIMESTAMP);
            }

            setStringOrNull(pstmt, 5, ts.getWorkPersonnel());
            setStringOrNull(pstmt, 6, ts.getWorkPeriod());
            setStringOrNull(pstmt, 7, ts.getSupportType());
            setStringOrNull(pstmt, 8, ts.getCaseOpenYn());
            setStringOrNull(pstmt, 9, ts.getOverview());
            setStringOrNull(pstmt, 10, ts.getCauseAnalysis());
            setStringOrNull(pstmt, 11, ts.getErrorContent());
            setStringOrNull(pstmt, 12, ts.getActionTaken());
            setStringOrNull(pstmt, 13, ts.getScriptContent());
            setStringOrNull(pstmt, 14, ts.getNote());
            pstmt.setInt(15, ts.getId());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 트러블 슈팅 삭제
    public boolean deleteTroubleshooting(int id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "DELETE FROM troubleshooting WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 빈 문자열을 NULL로 처리하는 도우미 메서드
    private void setStringOrNull(PreparedStatement pstmt, int parameterIndex, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) {
            pstmt.setNull(parameterIndex, Types.VARCHAR);
        } else {
            pstmt.setString(parameterIndex, value.trim());
        }
    }
}
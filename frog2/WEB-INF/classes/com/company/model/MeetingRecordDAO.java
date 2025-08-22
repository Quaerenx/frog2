package com.company.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.company.util.DBConnection;

public class MeetingRecordDAO {
    private static final int PAGE_SIZE = 20;

    // 페이징 처리된 회의록 목록 조회 (댓글 개수 포함)
    public List<MeetingRecordDTO> getMeetingRecords(int page) {
        List<MeetingRecordDTO> records = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT m.*, " +
                        "COALESCE(c.comment_count, 0) as comment_count " +
                        "FROM meeting_records m " +
                        "LEFT JOIN (SELECT meeting_id, COUNT(*) as comment_count FROM meeting_comments GROUP BY meeting_id) c " +
                        "ON m.meeting_id = c.meeting_id " +
                        "ORDER BY m.meeting_datetime DESC " +
                        "LIMIT ? OFFSET ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, PAGE_SIZE);
            pstmt.setInt(2, (page - 1) * PAGE_SIZE);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                MeetingRecordDTO record = new MeetingRecordDTO();
                record.setMeetingId(rs.getLong("meeting_id"));
                record.setTitle(rs.getString("title"));
                record.setMeetingDatetime(rs.getTimestamp("meeting_datetime"));
                record.setMeetingType(rs.getString("meeting_type"));
                record.setContent(rs.getString("content"));
                record.setAuthorId(rs.getString("author_id"));
                record.setAuthorName(rs.getString("author_name"));
                record.setViewCount(rs.getInt("view_count"));
                record.setCreatedAt(rs.getTimestamp("created_at"));
                record.setUpdatedAt(rs.getTimestamp("updated_at"));
                record.setCommentCount(rs.getInt("comment_count"));

                records.add(record);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return records;
    }

    // 전체 회의록 개수 조회 (페이징용)
    public int getTotalCount() {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM meeting_records";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return count;
    }

    // 특정 회의록 조회 (조회수 증가)
    public MeetingRecordDTO getMeetingRecord(Long meetingId) {
        MeetingRecordDTO record = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // 조회수 증가
            String updateSql = "UPDATE meeting_records SET view_count = view_count + 1 WHERE meeting_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setLong(1, meetingId);
            pstmt.executeUpdate();
            DBConnection.close(pstmt);

            // 회의록 조회
            String selectSql = "SELECT * FROM meeting_records WHERE meeting_id = ?";
            pstmt = conn.prepareStatement(selectSql);
            pstmt.setLong(1, meetingId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                record = new MeetingRecordDTO();
                record.setMeetingId(rs.getLong("meeting_id"));
                record.setTitle(rs.getString("title"));
                record.setMeetingDatetime(rs.getTimestamp("meeting_datetime"));
                record.setMeetingType(rs.getString("meeting_type"));
                record.setContent(rs.getString("content"));
                record.setAuthorId(rs.getString("author_id"));
                record.setAuthorName(rs.getString("author_name"));
                record.setViewCount(rs.getInt("view_count"));
                record.setCreatedAt(rs.getTimestamp("created_at"));
                record.setUpdatedAt(rs.getTimestamp("updated_at"));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return record;
    }

    // 회의록 추가
    public boolean addMeetingRecord(MeetingRecordDTO record) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO meeting_records (title, meeting_datetime, meeting_type, content, author_id, author_name) " +
                        "VALUES (?, ?, ?, ?, ?, ?)";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, record.getTitle());
            pstmt.setTimestamp(2, record.getMeetingDatetime());
            pstmt.setString(3, record.getMeetingType());
            pstmt.setString(4, record.getContent());
            pstmt.setString(5, record.getAuthorId());
            pstmt.setString(6, record.getAuthorName());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 회의록 수정
    public boolean updateMeetingRecord(MeetingRecordDTO record) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE meeting_records SET title = ?, meeting_datetime = ?, meeting_type = ?, " +
                        "content = ?, updated_at = statement_timestamp() WHERE meeting_id = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, record.getTitle());
            pstmt.setTimestamp(2, record.getMeetingDatetime());
            pstmt.setString(3, record.getMeetingType());
            pstmt.setString(4, record.getContent());
            pstmt.setLong(5, record.getMeetingId());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 회의록 삭제
    public boolean deleteMeetingRecord(Long meetingId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "DELETE FROM meeting_records WHERE meeting_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1, meetingId);

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 작성자 권한 확인
    public boolean isAuthor(Long meetingId, String userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean isAuthor = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT author_id FROM meeting_records WHERE meeting_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setLong(1, meetingId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String authorId = rs.getString("author_id");
                isAuthor = userId.equals(authorId);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return isAuthor;
    }

    // 페이지 크기 반환
    public static int getPageSize() {
        return PAGE_SIZE;
    }
}
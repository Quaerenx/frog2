package com.company.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.company.util.DBConnection;
import com.company.util.PasswordUtils;

public class UserDAO {

    // 사용자 인증 메소드
    public UserDTO authenticateUser(String userId, String password) {
        UserDTO user = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            // 1. SELECT 문에서 department 컬럼 삭제
            String sql = "SELECT userId, password, userName FROM company_users WHERE userId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                String hashedPassword = rs.getString("password");

                if (PasswordUtils.checkPassword(password, hashedPassword)) {
                    user = new UserDTO();
                    user.setUserId(rs.getString("userId"));
                    user.setPassword("");
                    user.setUserName(rs.getString("userName"));
                    // 2. DTO에 department를 설정하는 코드 삭제
                    // user.setDepartment(rs.getString("department"));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }
        return user;
    }

    // 새 사용자 등록 메소드
    public boolean registerUser(UserDTO user) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            // 3. INSERT 문에서 department 컬럼과 값(?) 삭제
            String sql = "INSERT INTO company_users (userId, password, userName) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, user.getUserId());
            pstmt.setString(2, PasswordUtils.hashPassword(user.getPassword()));
            pstmt.setString(3, user.getUserName());
            // 4. department 값을 설정하는 코드 삭제
            // pstmt.setString(4, user.getDepartment());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }
        return success;
    }

    // 사용자 비밀번호 변경 메소드 (department와 관련 없으므로 수정사항 없음)
    public boolean updatePassword(String userId, String newPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE company_users SET password = ? WHERE userId = ?";
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, PasswordUtils.hashPassword(newPassword));
            pstmt.setString(2, userId);

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }
        return success;
    }

    // ID로 사용자 정보 조회 메소드
    public UserDTO getUserById(String userId) {
        UserDTO user = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            // 5. SELECT 문에서 department 컬럼 삭제
            String sql = "SELECT userId, userName FROM company_users WHERE userId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                user = new UserDTO();
                user.setUserId(rs.getString("userId"));
                user.setUserName(rs.getString("userName"));
                // 6. DTO에 department를 설정하는 코드 삭제
                // user.setDepartment(rs.getString("department"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("데이터베이스 연결 중 오류가 발생했습니다: " + e.getMessage(), e);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("데이터베이스 드라이버를 찾을 수 없습니다: " + e.getMessage(), e);
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }
        return user;
    }
}
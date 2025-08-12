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
	    UserDTO user = null;  // 기본값으로 null 초기화
	    Connection conn = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;

	    try {
	        conn = DBConnection.getConnection();
	        // 비밀번호는 데이터베이스에서 가져와서 나중에 검증
	        String sql = "SELECT userId, password, userName, department FROM company_users WHERE userId = ?";
	        pstmt = conn.prepareStatement(sql);
	        pstmt.setString(1, userId);

	        rs = pstmt.executeQuery();

	        if (rs.next()) {
	            // 데이터베이스에서 가져온 해시된 비밀번호
	            String hashedPassword = rs.getString("password");

	            // 입력된 비밀번호와 해시된 비밀번호 비교
	            if (PasswordUtils.checkPassword(password, hashedPassword)) {
	                user = new UserDTO();
	                user.setUserId(rs.getString("userId"));
	                user.setPassword(""); // 보안을 위해 빈 문자열로 설정
	                user.setUserName(rs.getString("userName"));
	                user.setDepartment(rs.getString("department"));
	            }
	        }
	    } catch (SQLException | ClassNotFoundException e) {
	        e.printStackTrace();
	    } finally {
	        DBConnection.close(rs, pstmt, conn);
	    }

	    // 메소드 끝에 명시적으로 항상 user 객체를 반환 (null일 수도 있음)
	    return user;
	}

    // 새 사용자 등록 메소드 (회원가입 기능이 필요할 경우)
    public boolean registerUser(UserDTO user) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO company_users (userId, password, userName, department) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, user.getUserId());
            // 비밀번호 해싱 적용
            pstmt.setString(2, PasswordUtils.hashPassword(user.getPassword()));
            pstmt.setString(3, user.getUserName());
            pstmt.setString(4, user.getDepartment());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 사용자 비밀번호 변경 메소드
    public boolean updatePassword(String userId, String newPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE company_users SET password = ? WHERE userId = ?";
            pstmt = conn.prepareStatement(sql);

            // 새 비밀번호 해싱 적용
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

    // 기존의 getUserById 메소드는 그대로 유지
    public UserDTO getUserById(String userId) {
        UserDTO user = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT userId, userName, department FROM company_users WHERE userId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                user = new UserDTO();
                user.setUserId(rs.getString("userId"));
                user.setUserName(rs.getString("userName"));
                user.setDepartment(rs.getString("department"));
            }
        } catch (SQLException e) {
            // 구체적인 SQL 예외 처리
            throw new RuntimeException("데이터베이스 연결 중 오류가 발생했습니다: " + e.getMessage(), e);
        } catch (ClassNotFoundException e) {
            // JDBC 드라이버 로딩 예외 처리
            throw new RuntimeException("데이터베이스 드라이버를 찾을 수 없습니다: " + e.getMessage(), e);
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return user;
    }
}

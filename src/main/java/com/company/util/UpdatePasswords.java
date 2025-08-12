package com.company.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UpdatePasswords {

    public static void main(String[] args) {
        updateAllPasswords();
    }

    public static void updateAllPasswords() {
        Connection conn = null;
        PreparedStatement selectStmt = null;
        PreparedStatement updateStmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // 모든 사용자 ID와 비밀번호 조회
            String selectSql = "SELECT userId, password FROM company_users";
            selectStmt = conn.prepareStatement(selectSql);
            rs = selectStmt.executeQuery();

            // 비밀번호 업데이트 준비
            String updateSql = "UPDATE company_users SET password = ? WHERE userId = ?";
            updateStmt = conn.prepareStatement(updateSql);

            // 각 사용자의 비밀번호를 해싱하여 업데이트
            while (rs.next()) {
                String userId = rs.getString("userId");
                String plainPassword = rs.getString("password");

                // 비밀번호 해싱
                String hashedPassword = PasswordUtils.hashPassword(plainPassword);

                // 해시된 비밀번호로 업데이트
                updateStmt.setString(1, hashedPassword);
                updateStmt.setString(2, userId);
                updateStmt.executeUpdate();

                System.out.println("비밀번호 업데이트 완료: " + userId);
            }

            System.out.println("모든 비밀번호 업데이트 완료!");

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, selectStmt, updateStmt, conn);
        }
    }
}
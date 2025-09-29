// 1. 패키지 선언 (파일 위치와 일치시켜야 함)
package com.company.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;



// 2. public 클래스 선언 (파일 이름과 클래스 이름 일치)
public class UpdateAllPasswords {

    /**
     * 프로그램을 실행하기 위한 main 메소드
     */
    public static void main(String[] args) {
        updateUnhashedPasswords();
    }

    /**
     * 아직 해시 처리되지 않은 사용자들의 비밀번호를
     * 안전하고 효율적으로 업데이트하는 메소드
     */
    public static void updateUnhashedPasswords() {
        // --- 리소스 변수 선언 ---
        Connection conn = null;
        PreparedStatement selectStmt = null;
        PreparedStatement updateStmt = null;
        ResultSet rs = null;
        
        // --- 설정 변수 선언 ---
        final int BATCH_SIZE = 1000; // 1000건씩 묶어서 처리
        int count = 0;

        try {
            // --- DB 연결 ---
            conn = DBConnection.getConnection();
            
            // 3. 트랜잭션 시작 (자동 커밋 비활성화)
            conn.setAutoCommit(false);

            // 4. 처리 대상을 정확히 선택하는 SQL (상태 플래그 사용)
            String selectSql = "SELECT userId, password FROM company_users WHERE password_hashed = FALSE";
            selectStmt = conn.prepareStatement(selectSql);
            rs = selectStmt.executeQuery();

            // 5. 비밀번호와 상태 플래그를 함께 업데이트하는 SQL
            String updateSql = "UPDATE company_users SET password = ?, password_hashed = TRUE WHERE userId = ?";
            updateStmt = conn.prepareStatement(updateSql);

            // --- 루프를 돌며 배치 작업 수행 ---
            while (rs.next()) {
                String userId = rs.getString("userId");
                String plainPassword = rs.getString("password");

                // 비밀번호 해싱 (PasswordUtils는 별도로 구현되어 있다고 가정)
                String hashedPassword = PasswordUtils.hashPassword(plainPassword);

                updateStmt.setString(1, hashedPassword);
                updateStmt.setString(2, userId);
                
                // 6. 쿼리를 배치에 추가
                updateStmt.addBatch();
                count++;

                // 7. BATCH_SIZE 만큼 쌓이면 중간 실행
                if (count % BATCH_SIZE == 0) {
                    updateStmt.executeBatch();
                    System.out.println(count + " 건의 비밀번호 배치 업데이트 완료...");
                }
            }

            // 8. 루프 종료 후 남은 배치 실행
            updateStmt.executeBatch();
            
            // 9. 모든 작업이 성공했으므로 최종 커밋
            conn.commit();

            System.out.println("총 " + count + " 건의 모든 비밀번호 업데이트 성공!");

        } catch (Exception e) {
            e.printStackTrace();
            
            // 10. 예외 발생 시 롤백
            if (conn != null) {
                try {
                    conn.rollback();
                    System.err.println("오류 발생: 트랜잭션을 롤백합니다.");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            // 11. 사용한 리소스 정리
            DBConnection.close(rs, selectStmt, updateStmt, conn);
        }
    }
}
package com.company.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Vertica 데이터베이스 연결 정보
    private static final String URL = "jdbc:vertica://192.168.40.70:5433/vertica_web";
    private static final String USER = "vertica";
    private static final String PASSWORD = "vertica!";
    private static final String DRIVER = "com.vertica.jdbc.Driver";

    // 데이터베이스 연결을 가져오는 메소드
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName(DRIVER);
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // 자원 해제 메소드
    public static void close(AutoCloseable... resources) {
        for (AutoCloseable resource : resources) {
            if (resource != null) {
                try {
                    resource.close();
                } catch (Exception e) {
                    // 로그 기록 추가
                    System.err.println("리소스 종료 중 오류 발생: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
    }
}
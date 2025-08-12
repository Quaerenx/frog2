package com.company.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.company.util.DBConnection;

public class CustomerDAO {

    // 모든 고객사 정보 조회 (활성 상태만, 필터 옵션 추가)
    public List<CustomerDTO> getAllCustomers(String sortField, String sortDirection, String filter) {
        List<CustomerDTO> customerList = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // 기본 정렬 설정
            if (sortField == null || sortField.isEmpty()) {
                sortField = "customer_name";
            }
            if (sortDirection == null || sortDirection.isEmpty()) {
                sortDirection = "ASC";
            }

            // 필터 조건 추가
            String sql = "SELECT * FROM vertica_customer_info WHERE is_deleted = 1";
            if ("maintenance".equals(filter)) {
                sql += " AND customer_type = '정기점검 계약 고객사'";
            }
            sql += " ORDER BY " + sortField + " " + sortDirection;

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CustomerDTO customer = new CustomerDTO();
                customer.setCustomerName(rs.getString("customer_name"));
                customer.setFirstIntroductionYear(rs.getString("first_introduction_year"));
                customer.setDbName(rs.getString("db_name"));
                customer.setVerticaVersion(rs.getString("vertica_version"));
                customer.setVerticaEos(rs.getString("vertica_eos"));
                customer.setMode(rs.getString("mode"));
                customer.setOs(rs.getString("os"));
                customer.setNodes(rs.getString("nodes"));
                customer.setLicenseSize(rs.getString("license_size"));
                customer.setManagerName(rs.getString("manager_name"));
                customer.setSubManagerName(rs.getString("sub_manager_name"));
                customer.setSaid(rs.getString("said"));
                customer.setNote(rs.getString("note"));
                customer.setOsStorageConfig(rs.getString("os_storage_config"));
                customer.setBackupConfig(rs.getString("backup_config"));
                customer.setBiTool(rs.getString("bi_tool"));
                customer.setEtlTool(rs.getString("etl_tool"));
                customer.setDbEncryption(rs.getString("db_encryption"));
                customer.setCdcTool(rs.getString("cdc_tool"));
                customer.setCustomerType(rs.getString("customer_type"));

                customerList.add(customer);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return customerList;
    }

    // 기존 호환성을 위한 오버로드 메소드 (기본값: 전체 보기)
    public List<CustomerDTO> getAllCustomers(String sortField, String sortDirection) {
        return getAllCustomers(sortField, sortDirection, "all");
    }

    // 고객사 개수 조회 (필터별)
    public int getCustomerCount(String filter) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM vertica_customer_info WHERE is_deleted = 1";
            if ("maintenance".equals(filter)) {
                sql += " AND customer_type = '정기점검 계약 고객사'";
            }

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

    // 고객사 상세 정보 조회 (활성 상태만)
    public CustomerDTO getCustomerByName(String customerName) {
        CustomerDTO customer = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM vertica_customer_info WHERE customer_name = ? AND is_deleted = 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customerName);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                customer = new CustomerDTO();
                customer.setCustomerName(rs.getString("customer_name"));
                customer.setFirstIntroductionYear(rs.getString("first_introduction_year"));
                customer.setDbName(rs.getString("db_name"));
                customer.setVerticaVersion(rs.getString("vertica_version"));
                customer.setVerticaEos(rs.getString("vertica_eos"));
                customer.setMode(rs.getString("mode"));
                customer.setOs(rs.getString("os"));
                customer.setNodes(rs.getString("nodes"));
                customer.setLicenseSize(rs.getString("license_size"));
                customer.setManagerName(rs.getString("manager_name"));
                customer.setSubManagerName(rs.getString("sub_manager_name"));
                customer.setSaid(rs.getString("said"));
                customer.setNote(rs.getString("note"));
                customer.setOsStorageConfig(rs.getString("os_storage_config"));
                customer.setBackupConfig(rs.getString("backup_config"));
                customer.setBiTool(rs.getString("bi_tool"));
                customer.setEtlTool(rs.getString("etl_tool"));
                customer.setDbEncryption(rs.getString("db_encryption"));
                customer.setCdcTool(rs.getString("cdc_tool"));
                customer.setCustomerType(rs.getString("customer_type"));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, pstmt, conn);
        }

        return customer;
    }

    // 고객사 정보 업데이트 (활성 상태인 데이터만)
    public boolean updateCustomer(CustomerDTO customer) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE vertica_customer_info SET first_introduction_year = ?, db_name = ?, "
                    + "vertica_version = ?, vertica_eos = ?, mode = ?, os = ?, nodes = ?, license_size = ?, "
                    + "manager_name = ?, sub_manager_name = ?, said = ?, note = ?, os_storage_config = ?, "
                    + "backup_config = ?, bi_tool = ?, etl_tool = ?, db_encryption = ?, cdc_tool = ?, "
                    + "customer_type = ? WHERE customer_name = ? AND is_deleted = 1";

            pstmt = conn.prepareStatement(sql);
            setStringOrNull(pstmt, 1, customer.getFirstIntroductionYear());
            setStringOrNull(pstmt, 2, customer.getDbName());
            setStringOrNull(pstmt, 3, customer.getVerticaVersion());
            setStringOrNull(pstmt, 4, customer.getVerticaEos());
            setStringOrNull(pstmt, 5, customer.getMode());
            setStringOrNull(pstmt, 6, customer.getOs());
            setStringOrNull(pstmt, 7, customer.getNodes());
            setStringOrNull(pstmt, 8, customer.getLicenseSize());
            setStringOrNull(pstmt, 9, customer.getManagerName());
            setStringOrNull(pstmt, 10, customer.getSubManagerName());
            setStringOrNull(pstmt, 11, customer.getSaid());
            setStringOrNull(pstmt, 12, customer.getNote());
            setStringOrNull(pstmt, 13, customer.getOsStorageConfig());
            setStringOrNull(pstmt, 14, customer.getBackupConfig());
            setStringOrNull(pstmt, 15, customer.getBiTool());
            setStringOrNull(pstmt, 16, customer.getEtlTool());
            setStringOrNull(pstmt, 17, customer.getDbEncryption());
            setStringOrNull(pstmt, 18, customer.getCdcTool());
            setStringOrNull(pstmt, 19, customer.getCustomerType());
            pstmt.setString(20, customer.getCustomerName());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 새 고객사 추가 (is_deleted = 1로 활성 상태로 추가)
    public boolean addCustomer(CustomerDTO customer) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO vertica_customer_info (customer_name, first_introduction_year, db_name, "
                    + "vertica_version, vertica_eos, mode, os, nodes, license_size, manager_name, sub_manager_name, "
                    + "said, note, os_storage_config, backup_config, bi_tool, etl_tool, db_encryption, cdc_tool, "
                    + "customer_type, is_deleted) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customer.getCustomerName());
            setStringOrNull(pstmt, 2, customer.getFirstIntroductionYear());
            setStringOrNull(pstmt, 3, customer.getDbName());
            setStringOrNull(pstmt, 4, customer.getVerticaVersion());
            setStringOrNull(pstmt, 5, customer.getVerticaEos());
            setStringOrNull(pstmt, 6, customer.getMode());
            setStringOrNull(pstmt, 7, customer.getOs());
            setStringOrNull(pstmt, 8, customer.getNodes());
            setStringOrNull(pstmt, 9, customer.getLicenseSize());
            setStringOrNull(pstmt, 10, customer.getManagerName());
            setStringOrNull(pstmt, 11, customer.getSubManagerName());
            setStringOrNull(pstmt, 12, customer.getSaid());
            setStringOrNull(pstmt, 13, customer.getNote());
            setStringOrNull(pstmt, 14, customer.getOsStorageConfig());
            setStringOrNull(pstmt, 15, customer.getBackupConfig());
            setStringOrNull(pstmt, 16, customer.getBiTool());
            setStringOrNull(pstmt, 17, customer.getEtlTool());
            setStringOrNull(pstmt, 18, customer.getDbEncryption());
            setStringOrNull(pstmt, 19, customer.getCdcTool());
            setStringOrNull(pstmt, 20, customer.getCustomerType());

            int rowsAffected = pstmt.executeUpdate();
            success = (rowsAffected > 0);

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(pstmt, conn);
        }

        return success;
    }

    // 고객사 논리적 삭제 (is_deleted = 0으로 변경)
    public boolean deleteCustomer(String customerName) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE vertica_customer_info SET is_deleted = 0 WHERE customer_name = ? AND is_deleted = 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customerName);

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
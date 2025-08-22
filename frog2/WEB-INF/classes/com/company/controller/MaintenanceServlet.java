package com.company.controller;

import java.io.IOException;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.company.model.CustomerDAO;
import com.company.model.CustomerDTO;
import com.company.model.MaintenanceRecordDAO;
import com.company.model.MaintenanceRecordDTO;
import com.company.model.UserDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// @WebServlet("/maintenance") - web.xml에서 매핑하므로 주석 처리
public class MaintenanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 세션 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        UserDTO user = (UserDTO) session.getAttribute("user");
        request.setAttribute("user", user);

        // 뷰 타입 확인
        String viewType = request.getParameter("view");
        if (viewType == null || viewType.isEmpty()) {
            viewType = "cards";
        }

        MaintenanceRecordDAO maintenanceDAO = new MaintenanceRecordDAO();
        CustomerDAO customerDAO = new CustomerDAO();

        if ("cards".equals(viewType)) {
            // 담당자별 고객사 카드 목록 표시
            Map<String, List<CustomerDTO>> inspectorCustomers = getInspectorCustomersMap();
            request.setAttribute("inspectorCustomers", inspectorCustomers);
            request.setAttribute("viewType", "cards");
            request.getRequestDispatcher("/maintenance/maintenance_cards.jsp").forward(request, response);

        } else if ("history".equals(viewType)) {
            // 특정 고객사의 정기점검 이력 목록
            String customerName = request.getParameter("customerName");
            if (customerName != null && !customerName.isEmpty()) {
                // 해당 고객사의 정기점검 이력 조회
                List<MaintenanceRecordDTO> records = maintenanceDAO.getMaintenanceRecordsByCustomer(customerName);

                // 고객사 기본 정보 조회
                CustomerDTO customer = customerDAO.getCustomerByName(customerName);

                request.setAttribute("records", records);
                request.setAttribute("customer", customer);
                request.setAttribute("customerName", customerName);
                request.setAttribute("viewType", "history");
                request.getRequestDispatcher("/maintenance/maintenance_history.jsp").forward(request, response);
            } else {
                response.sendRedirect("maintenance?view=cards");
            }

        } else if ("add".equals(viewType)) {
            // 새 정기점검 이력 추가 폼
            String customerName = request.getParameter("customerName");
            request.setAttribute("customerName", customerName);
            request.setAttribute("viewType", "add");
            request.getRequestDispatcher("/maintenance/maintenance_add.jsp").forward(request, response);

        } else if ("edit".equals(viewType)) {
            // 정기점검 이력 수정 폼
            String maintenanceIdStr = request.getParameter("id");
            if (maintenanceIdStr != null && !maintenanceIdStr.isEmpty()) {
                try {
                    Long maintenanceId = Long.parseLong(maintenanceIdStr);
                    MaintenanceRecordDTO record = maintenanceDAO.getMaintenanceRecordById(maintenanceId);
                    if (record != null) {
                        request.setAttribute("record", record);
                        request.setAttribute("viewType", "edit");
                        request.getRequestDispatcher("/maintenance/maintenance_edit.jsp").forward(request, response);
                    } else {
                        session.setAttribute("error", "해당 정기점검 이력을 찾을 수 없습니다.");
                        response.sendRedirect("maintenance?view=cards");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("error", "잘못된 요청입니다.");
                    response.sendRedirect("maintenance?view=cards");
                }
            } else {
                response.sendRedirect("maintenance?view=cards");
            }

        } else {
            response.sendRedirect("maintenance?view=cards");
        }
    }

 // 담당자별 고객사 목록을 Map으로 구성 (정기점검 계약 고객사이면서 활성 상태인 것만)
    private Map<String, List<CustomerDTO>> getInspectorCustomersMap() {
        Map<String, List<CustomerDTO>> inspectorCustomers = new LinkedHashMap<>();
        CustomerDAO customerDAO = new CustomerDAO();

        try {
            // getAllCustomers 메소드가 이미 is_deleted = 1 조건을 포함하고 있음
            List<CustomerDTO> allCustomers = customerDAO.getAllCustomers("manager_name", "ASC");

            for (CustomerDTO customer : allCustomers) {
                String mainManager = customer.getManagerName();
                String customerType = customer.getCustomerType();

                // 정기점검 계약 고객사이고 담당자가 있는 경우만 포함
                // (is_deleted = 1 조건은 이미 getAllCustomers에서 필터링됨)
                if (mainManager != null && !mainManager.trim().isEmpty() &&
                    "정기점검 계약 고객사".equals(customerType)) {
                    inspectorCustomers.computeIfAbsent(mainManager.trim(), k -> new ArrayList<>()).add(customer);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return inspectorCustomers;
    }

    @Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 세션 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        String actionType = request.getParameter("action");
        MaintenanceRecordDAO maintenanceDAO = new MaintenanceRecordDAO();

        if ("add".equals(actionType)) {
            // 새 정기점검 이력 추가
            MaintenanceRecordDTO record = new MaintenanceRecordDTO();
            record.setCustomerName(request.getParameter("customer_name"));
            record.setInspectorName(request.getParameter("inspector_name"));
            record.setInspectionDate(parseDate(request.getParameter("inspection_date")));
            record.setVerticaVersion(request.getParameter("vertica_version"));
            record.setNote(request.getParameter("note"));

            boolean success = maintenanceDAO.addMaintenanceRecord(record);
            if (success) {
                session.setAttribute("message", "정기점검 이력이 성공적으로 추가되었습니다.");
            } else {
                session.setAttribute("error", "정기점검 이력 추가 중 오류가 발생했습니다.");
            }

            String customerName = record.getCustomerName();
            String encodedName = java.net.URLEncoder.encode(customerName, "UTF-8");
            response.sendRedirect("maintenance?view=history&customerName=" + encodedName);

        } else if ("update".equals(actionType)) {
            // 정기점검 이력 수정
            String maintenanceIdStr = request.getParameter("maintenance_id");
            if (maintenanceIdStr != null && !maintenanceIdStr.isEmpty()) {
                try {
                    MaintenanceRecordDTO record = new MaintenanceRecordDTO();
                    record.setMaintenanceId(Long.parseLong(maintenanceIdStr));
                    record.setCustomerName(request.getParameter("customer_name"));
                    record.setInspectorName(request.getParameter("inspector_name"));
                    record.setInspectionDate(parseDate(request.getParameter("inspection_date")));
                    record.setVerticaVersion(request.getParameter("vertica_version"));
                    record.setNote(request.getParameter("note"));

                    boolean success = maintenanceDAO.updateMaintenanceRecord(record);
                    if (success) {
                        session.setAttribute("message", "정기점검 이력이 성공적으로 수정되었습니다.");
                    } else {
                        session.setAttribute("error", "정기점검 이력 수정 중 오류가 발생했습니다.");
                    }

                    String customerName = record.getCustomerName();
                    String encodedName = java.net.URLEncoder.encode(customerName, "UTF-8");
                    response.sendRedirect("maintenance?view=history&customerName=" + encodedName);

                } catch (NumberFormatException e) {
                    session.setAttribute("error", "잘못된 요청입니다.");
                    response.sendRedirect("maintenance?view=cards");
                }
            }

        } else if ("delete".equals(actionType)) {
            // 정기점검 이력 삭제
            String maintenanceIdStr = request.getParameter("maintenance_id");
            String customerName = request.getParameter("customer_name");

            if (maintenanceIdStr != null && !maintenanceIdStr.isEmpty()) {
                try {
                    Long maintenanceId = Long.parseLong(maintenanceIdStr);
                    boolean success = maintenanceDAO.deleteMaintenanceRecord(maintenanceId);
                    if (success) {
                        session.setAttribute("message", "정기점검 이력이 성공적으로 삭제되었습니다.");
                    } else {
                        session.setAttribute("error", "정기점검 이력 삭제 중 오류가 발생했습니다.");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("error", "잘못된 요청입니다.");
                }
            }

            if (customerName != null && !customerName.isEmpty()) {
                String encodedName = java.net.URLEncoder.encode(customerName, "UTF-8");
                response.sendRedirect("maintenance?view=history&customerName=" + encodedName);
            } else {
                response.sendRedirect("maintenance?view=cards");
            }

        } else {
            response.sendRedirect("maintenance?view=cards");
        }
    }

    // 날짜 문자열을 Date 객체로 변환
    private Date parseDate(String dateString) {
        if (dateString == null || dateString.trim().isEmpty()) {
            return null;
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date utilDate = sdf.parse(dateString.trim());
            return new Date(utilDate.getTime());
        } catch (ParseException e) {
            return null;
        }
    }
}
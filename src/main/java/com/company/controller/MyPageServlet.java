package com.company.controller;

import java.io.IOException;
import java.util.List;

import com.company.model.MaintenanceRecordDAO;
import com.company.model.MaintenanceRecordDTO;
import com.company.model.TroubleshootingDAO;
import com.company.model.TroubleshootingDTO;
import com.company.model.UserDAO;
import com.company.model.UserDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class MyPageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 세션 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        UserDTO currentUser = (UserDTO) session.getAttribute("user");
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "view";
        }

        switch (action) {
            case "view":
                showMyPage(request, response, currentUser);
                break;
            case "editProfile":
                showEditProfile(request, response, currentUser);
                break;
            case "changePassword":
                showChangePassword(request, response);
                break;
            default:
                showMyPage(request, response, currentUser);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        UserDTO currentUser = (UserDTO) session.getAttribute("user");
        String action = request.getParameter("action");

        if ("updateProfile".equals(action)) {
            updateProfile(request, response, currentUser, session);
        } else if ("updatePassword".equals(action)) {
            updatePassword(request, response, currentUser);
        }
    }

    // 마이페이지 메인 화면
    private void showMyPage(HttpServletRequest request, HttpServletResponse response, UserDTO user) 
            throws ServletException, IOException {
        
        UserDAO userDAO = new UserDAO();
        UserDTO userInfo = userDAO.getUserById(user.getUserId());
        
        // 내가 작성한 Maintenance 기록 조회
        MaintenanceRecordDAO maintenanceDAO = new MaintenanceRecordDAO();
        List<MaintenanceRecordDTO> myMaintenanceRecords = 
            maintenanceDAO.getMaintenanceRecordsByInspector(user.getUserName());
        
        // 내가 작성한 Troubleshooting 조회
        TroubleshootingDAO troubleshootingDAO = new TroubleshootingDAO();
        List<TroubleshootingDTO> myTroubleshootings = 
            troubleshootingDAO.getTroubleshootingByCreator(user.getUserName());
        
        request.setAttribute("userInfo", userInfo);
        request.setAttribute("myMaintenanceRecords", myMaintenanceRecords);
        request.setAttribute("myTroubleshootings", myTroubleshootings);
        request.setAttribute("maintenanceCount", myMaintenanceRecords != null ? myMaintenanceRecords.size() : 0);
        request.setAttribute("troubleshootingCount", myTroubleshootings != null ? myTroubleshootings.size() : 0);
        
        request.getRequestDispatcher("/mypage/mypage.jsp").forward(request, response);
    }

    // 프로필 수정 화면
    private void showEditProfile(HttpServletRequest request, HttpServletResponse response, UserDTO user) 
            throws ServletException, IOException {
        
        UserDAO userDAO = new UserDAO();
        UserDTO userInfo = userDAO.getUserById(user.getUserId());
        
        request.setAttribute("userInfo", userInfo);
        request.getRequestDispatcher("/mypage/edit_profile.jsp").forward(request, response);
    }

    // 비밀번호 변경 화면
    private void showChangePassword(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/mypage/change_password.jsp").forward(request, response);
    }

    // 프로필 업데이트 처리
    private void updateProfile(HttpServletRequest request, HttpServletResponse response, 
                               UserDTO currentUser, HttpSession session) 
            throws ServletException, IOException {
        
        String userName = request.getParameter("userName");
        String department = request.getParameter("department");
        
        UserDAO userDAO = new UserDAO();
        boolean success = userDAO.updateUserProfile(currentUser.getUserId(), userName, department);
        
        if (success) {
            // 세션 업데이트
            currentUser.setUserName(userName);
            currentUser.setDepartment(department);
            session.setAttribute("user", currentUser);
            
            request.setAttribute("message", "프로필이 성공적으로 업데이트되었습니다.");
            request.setAttribute("messageType", "success");
        } else {
            request.setAttribute("message", "프로필 업데이트에 실패했습니다.");
            request.setAttribute("messageType", "error");
        }
        
        showMyPage(request, response, currentUser);
    }

    // 비밀번호 변경 처리
    private void updatePassword(HttpServletRequest request, HttpServletResponse response, UserDTO currentUser) 
            throws ServletException, IOException {
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // 비밀번호 확인
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("message", "새 비밀번호가 일치하지 않습니다.");
            request.setAttribute("messageType", "error");
            showChangePassword(request, response);
            return;
        }
        
        UserDAO userDAO = new UserDAO();
        
        // 현재 비밀번호 확인
        UserDTO authUser = userDAO.authenticateUser(currentUser.getUserId(), currentPassword);
        if (authUser == null) {
            request.setAttribute("message", "현재 비밀번호가 올바르지 않습니다.");
            request.setAttribute("messageType", "error");
            showChangePassword(request, response);
            return;
        }
        
        // 비밀번호 변경
        boolean success = userDAO.updatePassword(currentUser.getUserId(), newPassword);
        
        if (success) {
            request.setAttribute("message", "비밀번호가 성공적으로 변경되었습니다.");
            request.setAttribute("messageType", "success");
        } else {
            request.setAttribute("message", "비밀번호 변경에 실패했습니다.");
            request.setAttribute("messageType", "error");
        }
        
        showMyPage(request, response, currentUser);
    }
}

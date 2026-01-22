package com.company.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import com.company.model.HostDAO;
import com.company.model.HostDTO;
import com.company.model.UserDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class HostServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        UserDTO user = (UserDTO) session.getAttribute("user");
        request.setAttribute("user", user);

        HostDAO dao = new HostDAO();
        Map<String, HostDTO> map = dao.getAllHostsMap();
        request.setAttribute("hostMap", map != null ? map : new HashMap<>());

        request.getRequestDispatcher("/hosts/hosts_list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        String action = nvl(request.getParameter("action"));
        String ip = nvl(request.getParameter("ip"));

        if (!isValidHostIp(ip)) {
            session.setAttribute("error", "허용된 IP(192.168.40.1~254)만 입력 가능합니다.");
            response.sendRedirect("hosts");
            return;
        }

        HostDAO dao = new HostDAO();
        boolean ok = false;

        if ("save".equals(action)) {
            HostDTO dto = new HostDTO();
            dto.setIp(ip);
            dto.setUserName(trimOrNull(request.getParameter("user_name")));
            dto.setPurpose(trimOrNull(request.getParameter("purpose")));
            dto.setHostLocation(trimOrNull(request.getParameter("host_location")));
            dto.setNote(trimOrNull(request.getParameter("note")));
            String rowColor = trimOrNull(request.getParameter("row_color"));
            if (!isValidHexColorOrEmpty(rowColor)) {
                rowColor = null; // 잘못된 값은 무시
            }
            dto.setRowColor(rowColor);
            ok = dao.upsert(dto);
            if (ok) session.setAttribute("message", ip + " 저장되었습니다.");
            else session.setAttribute("error", "저장 중 오류가 발생했습니다.");
        } else if ("delete".equals(action)) {
            ok = dao.deleteByIp(ip);
            if (ok) session.setAttribute("message", ip + " 삭제되었습니다.");
            else session.setAttribute("error", "삭제할 데이터가 없거나 오류가 발생했습니다.");
        }

        response.sendRedirect("hosts");
    }

    private boolean isValidHostIp(String ip) {
        if (ip == null || !ip.startsWith("192.168.40.")) return false;
        try {
            String last = ip.substring(ip.lastIndexOf('.') + 1);
            int n = Integer.parseInt(last);
            return n >= 1 && n <= 254;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isValidHexColorOrEmpty(String c) {
        if (c == null || c.isEmpty()) return true; // 비움 허용
        return c.matches("#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})");
    }

    private String nvl(String v) { return v == null ? "" : v; }
    private String trimOrNull(String v) { return v == null ? null : v.trim(); }
    private String emptyToNull(String v) { return v != null && v.isEmpty() ? null : v; }
}
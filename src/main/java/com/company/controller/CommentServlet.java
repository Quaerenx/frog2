package com.company.controller;


import java.io.IOException;
import java.io.PrintWriter;

import com.company.model.MeetingCommentDAO;
import com.company.model.MeetingCommentDTO;
import com.company.model.UserDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// @WebServlet("/comment") - web.xml에서 매핑하므로 주석 처리
public class CommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 세션 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendJsonResponse(response, false, "로그인이 필요합니다.");
            return;
        }

        UserDTO user = (UserDTO) session.getAttribute("user");
        String actionType = request.getParameter("action");

        MeetingCommentDAO commentDAO = new MeetingCommentDAO();

        if ("add".equals(actionType)) {
            // 댓글 추가
            handleAddComment(request, response, user, commentDAO);

        } else if ("update".equals(actionType)) {
            // 댓글 수정
            handleUpdateComment(request, response, user, commentDAO);

        } else if ("delete".equals(actionType)) {
            // 댓글 삭제
            handleDeleteComment(request, response, user, commentDAO);

        } else {
            sendJsonResponse(response, false, "잘못된 요청입니다.");
        }
    }

    // 댓글 추가 처리
    private void handleAddComment(HttpServletRequest request, HttpServletResponse response,
                                 UserDTO user, MeetingCommentDAO commentDAO) throws IOException {
        try {
            String meetingIdStr = request.getParameter("meeting_id");
            String content = request.getParameter("content");

            if (meetingIdStr == null || meetingIdStr.isEmpty()) {
                sendJsonResponse(response, false, "회의록 ID가 필요합니다.");
                return;
            }

            if (content == null || content.trim().isEmpty()) {
                sendJsonResponse(response, false, "댓글 내용을 입력해주세요.");
                return;
            }

            Long meetingId = Long.parseLong(meetingIdStr);

            MeetingCommentDTO comment = new MeetingCommentDTO();
            comment.setMeetingId(meetingId);
            comment.setContent(content.trim());
            comment.setAuthorId(user.getUserId());
            comment.setAuthorName(user.getUserName());

            boolean success = commentDAO.addComment(comment);

            if (success) {
                sendJsonResponse(response, true, "댓글이 성공적으로 등록되었습니다.");
            } else {
                sendJsonResponse(response, false, "댓글 등록 중 오류가 발생했습니다.");
            }

        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "잘못된 회의록 ID입니다.");
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "댓글 등록 중 오류가 발생했습니다.");
        }
    }

    // 댓글 수정 처리
    private void handleUpdateComment(HttpServletRequest request, HttpServletResponse response,
                                   UserDTO user, MeetingCommentDAO commentDAO) throws IOException {
        try {
            String commentIdStr = request.getParameter("comment_id");
            String content = request.getParameter("content");

            if (commentIdStr == null || commentIdStr.isEmpty()) {
                sendJsonResponse(response, false, "댓글 ID가 필요합니다.");
                return;
            }

            if (content == null || content.trim().isEmpty()) {
                sendJsonResponse(response, false, "댓글 내용을 입력해주세요.");
                return;
            }

            Long commentId = Long.parseLong(commentIdStr);

            // 작성자 권한 확인
            if (!commentDAO.isCommentAuthor(commentId, user.getUserId())) {
                sendJsonResponse(response, false, "댓글 수정 권한이 없습니다.");
                return;
            }

            MeetingCommentDTO comment = new MeetingCommentDTO();
            comment.setCommentId(commentId);
            comment.setContent(content.trim());

            boolean success = commentDAO.updateComment(comment);

            if (success) {
                sendJsonResponse(response, true, "댓글이 성공적으로 수정되었습니다.");
            } else {
                sendJsonResponse(response, false, "댓글 수정 중 오류가 발생했습니다.");
            }

        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "잘못된 댓글 ID입니다.");
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "댓글 수정 중 오류가 발생했습니다.");
        }
    }

    // 댓글 삭제 처리
    private void handleDeleteComment(HttpServletRequest request, HttpServletResponse response,
                                   UserDTO user, MeetingCommentDAO commentDAO) throws IOException {
        try {
            String commentIdStr = request.getParameter("comment_id");

            if (commentIdStr == null || commentIdStr.isEmpty()) {
                sendJsonResponse(response, false, "댓글 ID가 필요합니다.");
                return;
            }

            Long commentId = Long.parseLong(commentIdStr);

            // 작성자 권한 확인
            if (!commentDAO.isCommentAuthor(commentId, user.getUserId())) {
                sendJsonResponse(response, false, "댓글 삭제 권한이 없습니다.");
                return;
            }

            boolean success = commentDAO.deleteComment(commentId);

            if (success) {
                sendJsonResponse(response, true, "댓글이 성공적으로 삭제되었습니다.");
            } else {
                sendJsonResponse(response, false, "댓글 삭제 중 오류가 발생했습니다.");
            }

        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "잘못된 댓글 ID입니다.");
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "댓글 삭제 중 오류가 발생했습니다.");
        }
    }

    // JSON 응답 전송 도우미 메서드
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        String jsonResponse = String.format("{\"success\":%b,\"message\":\"%s\"}",
                                          success,
                                          message.replace("\"", "\\\""));
        out.print(jsonResponse);
        out.flush();
    }
}
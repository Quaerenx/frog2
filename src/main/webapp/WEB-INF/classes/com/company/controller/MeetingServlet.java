package com.company.controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

import com.company.model.MeetingCommentDAO;
import com.company.model.MeetingCommentDTO;
import com.company.model.MeetingRecordDAO;
import com.company.model.MeetingRecordDTO;
import com.company.model.UserDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// @WebServlet("/meeting") - web.xml에서 매핑하므로 주석 처리
public class MeetingServlet extends HttpServlet {
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
            viewType = "list";
        }

        MeetingRecordDAO meetingDAO = new MeetingRecordDAO();

        if ("list".equals(viewType)) {
            // 회의록 목록 (페이징 처리)
            int page = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) {
						page = 1;
					}
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            List<MeetingRecordDTO> meetingList = meetingDAO.getMeetingRecords(page);
            int totalCount = meetingDAO.getTotalCount();
            int totalPages = (int) Math.ceil((double) totalCount / MeetingRecordDAO.getPageSize());

            request.setAttribute("meetingList", meetingList);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("viewType", "list");
            request.getRequestDispatcher("/meeting/meeting_list.jsp").forward(request, response);

        } else if ("view".equals(viewType)) {
            // 회의록 상세 조회
            String meetingIdStr = request.getParameter("id");
            if (meetingIdStr != null && !meetingIdStr.isEmpty()) {
                try {
                    Long meetingId = Long.parseLong(meetingIdStr);
                    MeetingRecordDTO meeting = meetingDAO.getMeetingRecord(meetingId);

                    if (meeting != null) {
                        // 댓글 목록 조회
                        MeetingCommentDAO commentDAO = new MeetingCommentDAO();
                        List<MeetingCommentDTO> comments = commentDAO.getCommentsByMeetingId(meetingId);

                        request.setAttribute("meeting", meeting);
                        request.setAttribute("comments", comments);
                        request.setAttribute("viewType", "view");
                        request.getRequestDispatcher("/meeting/meeting_view.jsp").forward(request, response);
                    } else {
                        session.setAttribute("error", "존재하지 않는 회의록입니다.");
                        response.sendRedirect("meeting?view=list");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("error", "잘못된 요청입니다.");
                    response.sendRedirect("meeting?view=list");
                }
            } else {
                response.sendRedirect("meeting?view=list");
            }

        } else if ("write".equals(viewType)) {
            // 회의록 작성 폼
            request.setAttribute("viewType", "write");
            request.getRequestDispatcher("/meeting/meeting_write.jsp").forward(request, response);

        } else if ("edit".equals(viewType)) {
            // 회의록 수정 폼
            String meetingIdStr = request.getParameter("id");
            if (meetingIdStr != null && !meetingIdStr.isEmpty()) {
                try {
                    Long meetingId = Long.parseLong(meetingIdStr);
                    MeetingRecordDTO meeting = meetingDAO.getMeetingRecord(meetingId);

                    if (meeting != null) {
                        // 작성자 권한 확인
                        if (meetingDAO.isAuthor(meetingId, user.getUserId())) {
                            request.setAttribute("meeting", meeting);
                            request.setAttribute("viewType", "edit");
                            request.getRequestDispatcher("/meeting/meeting_edit.jsp").forward(request, response);
                        } else {
                            session.setAttribute("error", "수정 권한이 없습니다.");
                            response.sendRedirect("meeting?view=view&id=" + meetingId);
                        }
                    } else {
                        session.setAttribute("error", "존재하지 않는 회의록입니다.");
                        response.sendRedirect("meeting?view=list");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("error", "잘못된 요청입니다.");
                    response.sendRedirect("meeting?view=list");
                }
            } else {
                response.sendRedirect("meeting?view=list");
            }

        } else {
            response.sendRedirect("meeting?view=list");
        }
    }

    @Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 세션 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        UserDTO user = (UserDTO) session.getAttribute("user");
        String actionType = request.getParameter("action");

        MeetingRecordDAO meetingDAO = new MeetingRecordDAO();

        if ("write".equals(actionType)) {
            // 새 회의록 작성
            MeetingRecordDTO meeting = new MeetingRecordDTO();
            meeting.setTitle(request.getParameter("title"));
            meeting.setMeetingDatetime(parseDateTime(request.getParameter("meeting_datetime")));
            meeting.setMeetingType(request.getParameter("meeting_type"));
            meeting.setContent(request.getParameter("content"));
            meeting.setAuthorId(user.getUserId());
            meeting.setAuthorName(user.getUserName());

            boolean success = meetingDAO.addMeetingRecord(meeting);
            if (success) {
                session.setAttribute("message", "회의록이 성공적으로 등록되었습니다.");
            } else {
                session.setAttribute("error", "회의록 등록 중 오류가 발생했습니다.");
            }
            response.sendRedirect("meeting?view=list");

        } else if ("update".equals(actionType)) {
            // 회의록 수정
            String meetingIdStr = request.getParameter("meeting_id");
            if (meetingIdStr != null && !meetingIdStr.isEmpty()) {
                try {
                    Long meetingId = Long.parseLong(meetingIdStr);

                    // 작성자 권한 확인
                    if (meetingDAO.isAuthor(meetingId, user.getUserId())) {
                        MeetingRecordDTO meeting = new MeetingRecordDTO();
                        meeting.setMeetingId(meetingId);
                        meeting.setTitle(request.getParameter("title"));
                        meeting.setMeetingDatetime(parseDateTime(request.getParameter("meeting_datetime")));
                        meeting.setMeetingType(request.getParameter("meeting_type"));
                        meeting.setContent(request.getParameter("content"));

                        boolean success = meetingDAO.updateMeetingRecord(meeting);
                        if (success) {
                            session.setAttribute("message", "회의록이 성공적으로 수정되었습니다.");
                        } else {
                            session.setAttribute("error", "회의록 수정 중 오류가 발생했습니다.");
                        }
                        response.sendRedirect("meeting?view=view&id=" + meetingId);
                    } else {
                        session.setAttribute("error", "수정 권한이 없습니다.");
                        response.sendRedirect("meeting?view=list");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("error", "잘못된 요청입니다.");
                    response.sendRedirect("meeting?view=list");
                }
            }

        } else if ("delete".equals(actionType)) {
            // 회의록 삭제
            String meetingIdStr = request.getParameter("meeting_id");
            if (meetingIdStr != null && !meetingIdStr.isEmpty()) {
                try {
                    Long meetingId = Long.parseLong(meetingIdStr);

                    // 작성자 권한 확인
                    if (meetingDAO.isAuthor(meetingId, user.getUserId())) {
                        boolean success = meetingDAO.deleteMeetingRecord(meetingId);
                        if (success) {
                            session.setAttribute("message", "회의록이 성공적으로 삭제되었습니다.");
                        } else {
                            session.setAttribute("error", "회의록 삭제 중 오류가 발생했습니다.");
                        }
                    } else {
                        session.setAttribute("error", "삭제 권한이 없습니다.");
                    }
                    response.sendRedirect("meeting?view=list");
                } catch (NumberFormatException e) {
                    session.setAttribute("error", "잘못된 요청입니다.");
                    response.sendRedirect("meeting?view=list");
                }
            }

        } else {
            response.sendRedirect("meeting?view=list");
        }
    }

    // 날짜시간 문자열을 Timestamp 객체로 변환
    private Timestamp parseDateTime(String dateTimeString) {
        if (dateTimeString == null || dateTimeString.trim().isEmpty()) {
            return null;
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            java.util.Date utilDate = sdf.parse(dateTimeString.trim());
            return new Timestamp(utilDate.getTime());
        } catch (ParseException e) {
            return null;
        }
    }
}
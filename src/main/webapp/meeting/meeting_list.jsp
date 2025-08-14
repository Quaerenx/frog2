<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="회의록 관리" scope="request" />
<c:set var="pageBodyClass" value="page-1050 page-customers" scope="request" />
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ include file="/includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/meeting.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/customers.css">

<div class="meeting-management customer-management">
    <t:pageHeader>
        <jsp:attribute name="title">
        	<i class="fas fa-clipboard-list"></i> 회의록 관리
        </jsp:attribute>
        <jsp:attribute name="subtitle">총 ${totalCount}개의 회의록이 등록되어 있습니다</jsp:attribute>
        <jsp:attribute name="actions">
            <a href="${pageContext.request.contextPath}/meeting?view=write" class="add-button"><i class="fas fa-pen"></i> 새 회의록 작성</a>
        </jsp:attribute>
    </t:pageHeader>
    
    <!-- 성공/에러 메시지 표시 -->
    <c:if test="${not empty sessionScope.message}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            ${sessionScope.message}
        </div>
        <c:remove var="message" scope="session" />
    </c:if>

    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i>
            ${sessionScope.error}
        </div>
        <c:remove var="error" scope="session" />
    </c:if>
    
    <!-- 회의록 목록 (troubleshooting_list 테이블 디자인 적용) -->
    <style>
        .troubleshooting-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .troubleshooting-table th {
            background: #f8fafc; color: #374151; font-weight: 600;
            padding: 1rem 0.75rem; text-align: center; border-bottom: 1px solid #e5e7eb;
            position: sticky; top: 0; z-index: 10; white-space: nowrap;
        }
        .troubleshooting-table tbody tr { transition: all 0.2s ease; border-bottom: 1px solid #f3f4f6; cursor: pointer; }
        .troubleshooting-table tbody tr:nth-child(even) { background-color: #fafbfc; }
        .troubleshooting-table tbody tr:hover { background-color: #f5f7fb; box-shadow: 0 2px 8px rgba(61, 90, 128, 0.10); }
        .troubleshooting-table td { padding: 0.75rem; border-right: 1px solid #f3f4f6; vertical-align: middle; color: #374151; }
        .troubleshooting-table td:last-child { border-right: none; }
        .title-link { color: #1f2937; text-decoration: none; font-weight: 500; }
        .title-link:hover { color: var(--primary); text-decoration: underline; }
    </style>

    <div class="table-container">
        <div class="table-wrapper">
            <c:choose>
                <c:when test="${not empty meetingList}">
                    <table class="troubleshooting-table">
                        <thead>
                            <tr>
                                <th>제목</th>
                                <th width="120">글쓴이</th>
                                <th width="160">회의 일시</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="meeting" items="${meetingList}">
                                <tr onclick="location.href='${pageContext.request.contextPath}/meeting?view=view&id=${meeting.meetingId}'">
                                    <td>
                                        <a href="${pageContext.request.contextPath}/meeting?view=view&id=${meeting.meetingId}"
                                           class="title-link" onclick="event.stopPropagation();">
                                            ${meeting.title}
                                        </a>
                                    </td>
                                    <td class="text-center">${meeting.authorName}</td>
                                    <td class="text-center">
                                        <fmt:formatDate value="${meeting.meetingDatetime}" pattern="yyyy-MM-dd HH:mm"/>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <!-- 페이징 -->
                    <div class="pagination-container">
                        <div class="page-info">
                            ${currentPage} / ${totalPages} 페이지 (총 ${totalCount}건)
                        </div>
                        <div class="pagination">
                            <c:if test="${currentPage > 1}">
                                <a href="?view=list&page=1" class="page-link"><i class="fas fa-angle-double-left"></i></a>
                                <a href="?view=list&page=${currentPage - 1}" class="page-link"><i class="fas fa-angle-left"></i></a>
                            </c:if>
                            <c:set var="startPage" value="${currentPage - 2}" />
                            <c:set var="endPage" value="${currentPage + 2}" />
                            <c:if test="${startPage < 1}"><c:set var="startPage" value="1" /></c:if>
                            <c:if test="${endPage > totalPages}"><c:set var="endPage" value="${totalPages}" /></c:if>
                            <c:forEach var="i" begin="${startPage}" end="${endPage}">
                                <c:choose>
                                    <c:when test="${i == currentPage}"><span class="page-link active">${i}</span></c:when>
                                    <c:otherwise><a href="?view=list&page=${i}" class="page-link">${i}</a></c:otherwise>
                                </c:choose>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}">
                                <a href="?view=list&page=${currentPage + 1}" class="page-link"><i class="fas fa-angle-right"></i></a>
                                <a href="?view=list&page=${totalPages}" class="page-link"><i class="fas fa-angle-double-right"></i></a>
                            </c:if>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-clipboard"></i>
                        <h3>등록된 회의록이 없습니다</h3>
                        <p>첫 번째 회의록을 작성해보세요.</p>
                        <a href="${pageContext.request.contextPath}/meeting?view=write" class="add-button">
                            <i class="fas fa-pen"></i>
                            회의록 작성하기
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // 테이블 행 클릭 시 상세 페이지로 이동
    const tableRows = document.querySelectorAll('.meeting-table tbody tr');
    tableRows.forEach(row => {
        row.addEventListener('click', function(e) {
            // 액션 버튼 클릭 시에는 이벤트 무시
            if (e.target.closest('.action-button')) {
                return;
            }
            
            const titleLink = this.querySelector('.title-link');
            if (titleLink) {
                window.location.href = titleLink.href;
            }
        });
        
        // 마우스 오버 시 포인터 커서
        row.style.cursor = 'pointer';
    });
});
</script>

<%@ include file="/includes/footer.jsp" %>
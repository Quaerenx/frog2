<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="회의록 관리" scope="request" />
<%@ include file="/includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/meeting.css">

<div class="meeting-management">
    <div class="page-header">
        <div class="meeting-header-actions">
            <div>
                <h1><i class="fas fa-clipboard-list"></i> 회의록 관리</h1>
                <p class="lead">총 ${totalCount}개의 회의록이 등록되어 있습니다</p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/meeting?view=write" class="write-button">
                    <i class="fas fa-pen"></i>
                    새 회의록 작성
                </a>
            </div>
        </div>
    </div>
    
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
    
    <!-- 회의록 목록 -->
    <div class="meeting-container">
        <c:choose>
            <c:when test="${not empty meetingList}">
                <table class="meeting-table">
                    <thead>
                        <tr>
                            <th class="col-title">제목</th>
                            <th class="col-type">회의 유형</th>
                            <th class="col-datetime">회의 일시</th>
                            <th class="col-author">작성자</th>
                            <th class="col-stats">조회/댓글</th>
                            <th class="col-date">등록일</th>
                            <th class="col-actions">관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="meeting" items="${meetingList}">
                            <tr>
                                <td class="col-title">
                                    <a href="${pageContext.request.contextPath}/meeting?view=view&id=${meeting.meetingId}" 
                                       class="title-link" title="${meeting.title}">
                                        ${meeting.title}
                                    </a>
                                </td>
                                <td class="col-type">
                                    <span class="type-badge type-${meeting.meetingType.toLowerCase()}">${meeting.meetingType}</span>
                                </td>
                                <td class="col-datetime">
                                    <fmt:formatDate value="${meeting.meetingDatetime}" pattern="MM/dd HH:mm"/>
                                </td>
                                <td class="col-author">${meeting.authorName}</td>
                                <td class="col-stats">
                                    <div class="stats-info">
                                        <span class="view-count">
                                            <i class="fas fa-eye"></i> ${meeting.viewCount}
                                        </span>
                                        <span class="comment-count">
                                            <i class="fas fa-comment"></i> ${meeting.commentCount}
                                        </span>
                                    </div>
                                </td>
                                <td class="col-date">
                                    <fmt:formatDate value="${meeting.createdAt}" pattern="MM/dd"/>
                                </td>
                                <td class="col-actions">
                                    <c:if test="${meeting.authorId == user.userId}">
                                        <a href="${pageContext.request.contextPath}/meeting?view=edit&id=${meeting.meetingId}" 
                                           class="action-button" title="수정">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                    </c:if>
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
                        <!-- 이전 페이지 -->
                        <c:if test="${currentPage > 1}">
                            <a href="?view=list&page=1" class="page-link">
                                <i class="fas fa-angle-double-left"></i>
                            </a>
                            <a href="?view=list&page=${currentPage - 1}" class="page-link">
                                <i class="fas fa-angle-left"></i>
                            </a>
                        </c:if>
                        
                        <!-- 페이지 번호 -->
                        <c:set var="startPage" value="${currentPage - 2}" />
                        <c:set var="endPage" value="${currentPage + 2}" />
                        
                        <c:if test="${startPage < 1}">
                            <c:set var="startPage" value="1" />
                        </c:if>
                        <c:if test="${endPage > totalPages}">
                            <c:set var="endPage" value="${totalPages}" />
                        </c:if>
                        
                        <c:forEach var="i" begin="${startPage}" end="${endPage}">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <span class="page-link active">${i}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?view=list&page=${i}" class="page-link">${i}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                        
                        <!-- 다음 페이지 -->
                        <c:if test="${currentPage < totalPages}">
                            <a href="?view=list&page=${currentPage + 1}" class="page-link">
                                <i class="fas fa-angle-right"></i>
                            </a>
                            <a href="?view=list&page=${totalPages}" class="page-link">
                                <i class="fas fa-angle-double-right"></i>
                            </a>
                        </c:if>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fas fa-clipboard"></i>
                    <h3>등록된 회의록이 없습니다</h3>
                    <p>첫 번째 회의록을 작성해보세요.</p>
                    <a href="${pageContext.request.contextPath}/meeting?view=write" class="write-button">
                        <i class="fas fa-pen"></i>
                        회의록 작성하기
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
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
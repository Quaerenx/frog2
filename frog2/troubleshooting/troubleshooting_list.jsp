<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="트러블 슈팅" scope="request" />
<%@ include file="/includes/header.jsp" %>

<style>
    .troubleshooting-management {
        width: 100%;
	min-height: 800px;
        max-width: 1000px;
        margin: 0 auto;
        padding: var(--space-32) var(--space-16);
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    .page-header {
        background: #ffffff;
        color: #2c3e50;
        padding: 2rem;
        border-radius: 12px;
        margin-bottom: 1.5rem;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
        border: 1px solid #e8ecef;
    }
    
    .page-header h1 {
        margin: 0 0 0.5rem 0;
        font-size: 2rem;
        font-weight: 700;
        color: #2c3e50;
    }
    
    .page-header .lead {
        margin: 0;
        color: #6c757d;
        font-size: 1.1rem;
    }
    
    .add-button {
        background: var(--primary);
        color: white;
        padding: 0.75rem 1.5rem;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 500;
        transition: all 0.2s ease;
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
    
    .add-button:hover {
        background: #2f4968;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(61, 90, 128, 0.25);
        color: white;
        text-decoration: none;
    }
    
    .alert {
        padding: 1rem 1.25rem;
        margin-bottom: 1.5rem;
        border-radius: 8px;
        border: none;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    }
    
    .alert-success {
        background: #f0fdf4;
        color: #166534;
        border-left: 4px solid #22c55e;
    }
    
    .alert-danger {
        background: #fef2f2;
        color: #991b1b;
        border-left: 4px solid #ef4444;
    }
    
    .table-container {
        background: white;
        border-radius: 12px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        overflow: hidden;
        border: 1px solid #e5e7eb;
    }
    
    .table-wrapper {
        overflow-x: auto;
        max-width: 100%;
    }
    
    .troubleshooting-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
    }
    
    .troubleshooting-table th {
        background: #f8fafc;
        color: #374151;
        font-weight: 600;
        padding: 1rem 0.75rem;
        text-align: center;
        border-bottom: 1px solid #e5e7eb;
        position: sticky;
        top: 0;
        z-index: 10;
        white-space: nowrap;
    }
    
    .troubleshooting-table tbody tr {
        transition: all 0.2s ease;
        border-bottom: 1px solid #f3f4f6;
        cursor: pointer;
    }
    
    .troubleshooting-table tbody tr:nth-child(even) {
        background-color: #fafbfc;
    }
    
    .troubleshooting-table tbody tr:hover {
        background-color: #f5f7fb;
        box-shadow: 0 2px 8px rgba(61, 90, 128, 0.10);
    }
    
    .troubleshooting-table td {
        padding: 0.75rem;
        border-right: 1px solid #f3f4f6;
        vertical-align: middle;
        color: #374151;
    }
    
    .troubleshooting-table td:last-child {
        border-right: none;
    }
    
    .title-link {
        color: #1f2937;
        text-decoration: none;
        font-weight: 500;
    }
    
    .title-link:hover {
        color: var(--primary);
        text-decoration: underline;
    }
    
    .action-buttons {
        display: flex;
        gap: 0.25rem;
        justify-content: center;
    }
    
    .btn {
        padding: 0.25rem 0.5rem;
        border-radius: 4px;
        text-decoration: none;
        font-size: 0.75rem;
        font-weight: 400;
        transition: all 0.2s ease;
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 0.25rem;
    }
    
    .btn-view {
        background: #6b7280;
        color: white;
    }
    
    .btn-view:hover {
        background: #4b5563;
        color: white;
        text-decoration: none;
    }
    
    .btn-edit {
        background: #059669;
        color: white;
    }
    
    .btn-edit:hover {
        background: #047857;
        color: white;
        text-decoration: none;
    }
    
    .btn-delete {
        background: #dc2626;
        color: white;
    }
    
    .btn-delete:hover {
        background: #b91c1c;
        color: white;
        text-decoration: none;
    }
    
    .empty-state {
        text-align: center;
        padding: 3rem;
        color: #9ca3af;
        font-style: italic;
    }
    
    .empty-state i {
        font-size: 3rem;
        margin-bottom: 1rem;
        opacity: 0.5;
    }
    
    /* 반응형 디자인 */
    @media (max-width: 768px) {
        .troubleshooting-management {
            max-width: 100%;
            padding: var(--space-24) var(--space-16);
        }
        
        .page-header {
            padding: 1.5rem;
        }
        
        .page-header h1 {
            font-size: 1.5rem;
        }
        
        .troubleshooting-table {
            font-size: 12px;
        }
        
        .troubleshooting-table th,
        .troubleshooting-table td {
            padding: 0.5rem;
        }
    }
</style>

<div class="troubleshooting-management">
    <div class="page-header">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1><i class="fas fa-tools"></i> 트러블 슈팅</h1>
                <p class="lead">기술지원 및 문제 해결 이력: <strong>${troubleshootingList.size()}</strong>건</p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/troubleshooting?view=add" class="add-button">
                    <i class="fas fa-plus"></i>
                    새 트러블 슈팅 등록
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
    
    <div class="table-container">
        <div class="table-wrapper">
            <table class="troubleshooting-table">
                <thead>
                    <tr>
                        <th>제목</th>
                        <th width="200">고객사</th>
                        <th width="150">발생일자</th>
                        <th width="120">작성자</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="ts" items="${troubleshootingList}" varStatus="status">
                        <tr onclick="location.href='${pageContext.request.contextPath}/troubleshooting?view=view&id=${ts.id}'">
                            <td>
                                <a href="${pageContext.request.contextPath}/troubleshooting?view=view&id=${ts.id}" 
                                   class="title-link" onclick="event.stopPropagation();">
                                    ${ts.title}
                                </a>
                            </td>
                            <td class="text-center">${ts.customerName}</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${not empty ts.occurrenceDate}">
                                        <fmt:formatDate value="${ts.occurrenceDate}" pattern="yyyy-MM-dd" />
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">${ts.creator}</td>
                            
                        </tr>
                    </c:forEach>
                    
                    <c:if test="${empty troubleshootingList}">
                        <tr>
                            <td colspan="4" class="empty-state">
                                <i class="fas fa-tools"></i>
                                <div>등록된 트러블 슈팅이 없습니다.</div>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    // 테이블 로딩 애니메이션
    $(document).ready(function() {
        $('.troubleshooting-table tbody tr').each(function(index) {
            $(this).css('animation-delay', (index * 0.05) + 's');
        });
    });
</script>

<%@ include file="/includes/footer.jsp" %>

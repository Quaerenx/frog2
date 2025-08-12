<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="정기점검 이력관리" scope="request" />
<%@ include file="/includes/header.jsp" %>

<style>
	.maintenance-management {
	    width: 100%;
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
        text-align: center;
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
    
    /* 담당자별 섹션 */
    .inspector-section {
        margin-bottom: 2rem;
    }
    
    .inspector-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 12px 12px 0 0;
        margin-bottom: 0;
        display: flex;
        align-items: center;
        gap: 0.75rem;
        font-size: 1.2rem;
        font-weight: 600;
        box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
    }
    
    .inspector-header i {
        font-size: 1.4rem;
    }
    
    .customer-count {
        background: rgba(255, 255, 255, 0.2);
        padding: 0.25rem 0.75rem;
        border-radius: 12px;
        font-size: 0.9rem;
        margin-left: auto;
    }
    
    /* 카드 그리드 */
    .customer-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 1.5rem;
        padding: 1.5rem;
        background: #f8fafc;
        border-radius: 0 0 12px 12px;
        border: 1px solid #e5e7eb;
        border-top: none;
    }
    
    /* 고객사 카드 */
    .customer-card {
        background: white;
        border-radius: 12px;
        padding: 1.5rem;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        border: 1px solid #e5e7eb;
        transition: all 0.3s ease;
        cursor: pointer;
        position: relative;
        overflow: hidden;
    }
    
    .customer-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #3b82f6, #10b981);
        transform: scaleX(0);
        transition: transform 0.3s ease;
    }
    
    .customer-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 12px 25px rgba(0, 0, 0, 0.15);
        border-color: #3b82f6;
    }
    
    .customer-card:hover::before {
        transform: scaleX(1);
    }
    
    .customer-name {
        font-size: 1.1rem;
        font-weight: 600;
        color: #1f2937;
        margin-bottom: 0.75rem;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
    
    .customer-name i {
        color: #3b82f6;
        font-size: 1rem;
    }
    
    .customer-info {
        display: grid;
        gap: 0.5rem;
        font-size: 0.875rem;
        color: #6b7280;
    }
    
    .info-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0.25rem 0;
    }
    
    .info-label {
        font-weight: 500;
        color: #374151;
    }
    
    .info-value {
        color: #6b7280;
        text-align: right;
        max-width: 150px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
    
    .version-badge {
        background: #f0f9ff;
        color: #0369a1;
        padding: 0.125rem 0.5rem;
        border-radius: 6px;
        font-size: 0.75rem;
        font-weight: 500;
    }
    
    .mode-badge {
        background: #f0fdf4;
        color: #166534;
        padding: 0.125rem 0.5rem;
        border-radius: 6px;
        font-size: 0.75rem;
        font-weight: 500;
    }
    
    .card-footer {
        margin-top: 1rem;
        padding-top: 1rem;
        border-top: 1px solid #f3f4f6;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .view-history-btn {
        background: linear-gradient(135deg, #10b981, #059669);
        color: white;
        padding: 0.5rem 1rem;
        border-radius: 6px;
        text-decoration: none;
        font-size: 0.875rem;
        font-weight: 500;
        transition: all 0.2s ease;
        display: inline-flex;
        align-items: center;
        gap: 0.375rem;
        border: none;
        cursor: pointer;
    }
    
    .view-history-btn:hover {
        background: linear-gradient(135deg, #059669, #047857);
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        color: white;
        text-decoration: none;
    }
    
    .empty-state {
        text-align: center;
        padding: 3rem;
        color: #9ca3af;
        font-style: italic;
        background: white;
        border-radius: 12px;
        border: 2px dashed #d1d5db;
    }
    
    .empty-state i {
        font-size: 3rem;
        margin-bottom: 1rem;
        opacity: 0.5;
    }
    
    /* 반응형 디자인 */
	@media (max-width: 768px) {
	    .maintenance-management {
	        max-width: 100%;
	        padding: var(--space-24) var(--space-16);
	    }
        
        .page-header {
            padding: 1.5rem;
        }
        
        .page-header h1 {
            font-size: 1.5rem;
        }
        
        .customer-grid {
            grid-template-columns: 1fr;
            gap: 1rem;
            padding: 1rem;
        }
        
        .inspector-header {
            font-size: 1.1rem;
            padding: 0.875rem 1rem;
        }
        
        .customer-card {
            padding: 1rem;
        }
        
        .info-value {
            max-width: 120px;
        }
    }
    
    @media (max-width: 480px) {
        .customer-grid {
            padding: 0.75rem;
        }
        
        .customer-card {
            padding: 0.875rem;
        }
        
        .info-row {
            flex-direction: column;
            align-items: flex-start;
            gap: 0.25rem;
        }
        
        .info-value {
            max-width: none;
            text-align: left;
        }
        
    }
</style>

<div class="maintenance-management">
    <div class="page-header">
        <h1><i class="fas fa-clipboard-check"></i> 정기점검 이력관리</h1>
        <p class="lead">담당자별 고객사를 선택하여 정기점검 이력을 관리하세요</p>
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
    
    <!-- 담당자별 고객사 카드 목록 -->
    <c:choose>
        <c:when test="${not empty inspectorCustomers}">
            <c:forEach var="entry" items="${inspectorCustomers}">
                <div class="inspector-section">
                    <div class="inspector-header">
                        <i class="fas fa-user-tie"></i>
                        <span>${entry.key}</span>
                        <span class="customer-count">${entry.value.size()}개 고객사</span>
                    </div>
                    
                    <div class="customer-grid">
                        <c:forEach var="customer" items="${entry.value}">
                            <div class="customer-card" 
                                 onclick="location.href='${pageContext.request.contextPath}/maintenance?view=history&customerName=${customer.customerName}'">
                                
                                <div class="customer-name">
                                    <i class="fas fa-building"></i>
                                    ${customer.customerName}
                                </div>
                                
                                <div class="customer-info">
                                    <div class="info-row">
                                        <span class="info-label">도입년도</span>
                                        <span class="info-value">${customer.firstIntroductionYear}</span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">DB명</span>
                                        <span class="info-value" title="${customer.dbName}">${customer.dbName}</span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">버전</span>
                                        <span class="info-value">
                                            <c:if test="${not empty customer.verticaVersion}">
                                                <span class="version-badge">${customer.verticaVersion}</span>
                                            </c:if>
                                        </span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">모드</span>
                                        <span class="info-value">
                                            <c:if test="${not empty customer.mode}">
                                                <span class="mode-badge">${customer.mode}</span>
                                            </c:if>
                                        </span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">노드수</span>
                                        <span class="info-value">${customer.nodes}</span>
                                    </div>
                                </div>
                                
                                <div class="card-footer">
                                    <div class="text-muted" style="font-size: 0.75rem;">
                                        클릭하여 점검 이력 보기
                                    </div>
                                    <div class="view-history-btn">
                                        <i class="fas fa-history"></i>
                                        이력 보기
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <i class="fas fa-users"></i>
                <div>등록된 고객사 정보가 없습니다.</div>
                <p>먼저 고객사 정보를 등록해주세요.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // 카드 호버 효과 강화
    const cards = document.querySelectorAll('.customer-card');
    
    cards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-6px) scale(1.02)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
    
    // 카드 클릭 시 로딩 효과
    cards.forEach(card => {
        card.addEventListener('click', function() {
            this.style.opacity = '0.7';
            this.style.transform = 'scale(0.98)';
        });
    });
});
</script>

<%@ include file="/includes/footer.jsp" %>